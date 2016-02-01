//
//  User.swift
//  idrop.link
//
//  Created by Christian Schulze on 17/04/15.
//  Copyright (c) 2015 Christian Schulze. All rights reserved.
//

import Foundation
import KeychainAccess

/**
Wrapper class for user specific API operations and data handling of an instance
of a User.
*/
public class User {
    var email: String?
    var password: String?
    var userId: String?
    var token: String?

    var onDropSync: () -> Void

    var drops:Array<Drop> {
        didSet {
            self.onDropSync()
        }
    }

    var keychain: Keychain

    var onProgress:(Float) -> Void

    // MARK: - Initializers
    public init() {
        self.onProgress = { (prog) -> Void in }
        self.onDropSync = { () -> Void in }
        self.email = nil
        self.password = nil
        self.userId = nil
        self.keychain = Keychain(service: Config.keychainServiceEntity)
        self.drops = [Drop]()
    }

    /**
    Initialize user with credentials (from keychain or similar)

    :param: email       the users email
    :param: password    the users password
    :param: userId      the users id as returned by the api

    :return: new user object
    */
    public init(email: String, password: String, userId: String) {
        self.onProgress = { (prog) -> Void in }
        self.onDropSync = { () -> Void in }
        self.email = email
        self.password = password
        self.userId = userId
        self.keychain = Keychain(service: Config.keychainServiceEntity)
            .label("idrop.link (OSX App)")
            .synchronizable(true)
            .accessibility(.WhenUnlocked)
        self.drops = [Drop]()
    }

    // MARK: - User specific api calls
    /**
    Create new user

    :param: email the users email
    :param: password the users password
    :param: callback closure `(Bool, String)` to be executed after finished

    :returns: user  id as returned by the api
    */
    public func createUser(email: String, password: String, callback: (Bool, String) -> ()) {
        Networking.createUser(email, password: password, callback: { (returnedJson, error) in
            // TODO: we should also check for the status code here
            if (error != nil) {
                if let json = returnedJson {
                    callback(false, json["message"].string!)
                } else {
                    callback(false, "no message returned")
                }
            } else {
                if let json = returnedJson {
                    self.setCredentials(email, password: password, id: json["_id"].string)

                    if let id = self.userId {
                        self.tryKeychainDataSet()
                        callback(true, id)
                    } else {
                        callback(false, json["message"].string!)
                    }
                } else {
                    callback(false, "no message or id returned")
                }
            }
        })
    }

    /**
    Get access token to send authenticated subsequent requests to the api.

    :param: callback closure `(Bool, String)` to be executed after finished

    :see: tryLogin
    */
    public func login(callback: (Bool, String) -> ()) {
        Networking.getToken(self.userId,
            email: self.email,
            password: self.password,
            callback: { (returnedJson, error) in
                if (error != nil) {
                    if let json = returnedJson {
                        callback(false, json["message"].string!)

                    } else {
                        self.logout()

                        // the user does not exist anymore, so we can delete all
                        // saved credentials
                        if error!.code == 404 {
                            do {
                                try self.keychain.removeAll()
                            } catch _ {}
                            callback(false, "A user for this email does not exist.")

                        } else if error!.code == 400 || error!.code == 401 {
                            do {
                                try self.keychain.removeAll()
                            } catch {}
                            callback(false, "Please check your credentials and try again.")

                        } else {
                            // TODO: improve
                            callback(false, "Unknown error.")
                        }
                    }

                } else {
                    if let json = returnedJson {
                        if let token = json["token"].string {
                            self.token = token
                            self.syncDrops()
                            callback(true, self.token!)

                        } else {
                            self.logout()
                            callback(false, "An error occuroed.")
                        }

                    } else {
                        self.logout()
                        callback(false, "An error occured.")
                    }
                }
        })
    }

    /**
    Unsets the user credentials (which represent the "not logged in" state).

    :return: success indicator
    */
    public func logout() -> Bool {
        self.email = nil
        self.password = nil
        self.userId = nil

        self.drops = []

        return !self.hasCredentials()
    }

    /**
    Try to get access token if we have the credentials

    :see: login
    */
    public func tryLogin(callback: (Bool) -> ()) {
        if (self.hasCredentials()) {
            self.login({ (success, msg) in
                if (success) {
                    callback(true)
                } else {
                    self.logout()
                    callback(false)
                }
            })
        }
    }

    // MARK: - Credentials
    /**
    Set credentials for the user

    :param: email the users email
    :param: password the users password
    :param: id the users id as returned by createUser

    :see: createUser
    */
    public func setCredentials(email: String?, password: String?, id: String?) {
        self.email = email
        self.password = password
        self.userId = id
    }

    /**
    Checks if credentials are set

    :returns: whether or not the credentials are set
    */
    public func hasCredentials() -> Bool {
        return (self.email != nil) && (self.password != nil) && (self.userId != nil)
    }

    // MARK: - Keychain specific functions
    /**
    Try to get saved credentials from the keychain if any

    :returns: whether or not the operation succeeded
    */
    public func tryKeychainDataFetch() -> Bool {
        var mail:String? = nil
        var pass:String? = nil
        var id:String? = nil

        do {
            mail = try self.keychain.get(Config.keychainUserEmailKey)
            pass = try self.keychain.get(Config.keychainUserPasswordKey)
            id = try self.keychain.get(Config.keychainUserIdKey)
        } catch _ {
            // most probably false
            return self.hasCredentials()
        }
        
        if (mail != nil && pass != nil && id != nil) {
            self.setCredentials(mail, password: pass, id: id)
        } else {
            // try to remove the keys if the credential set is incomplete
            // we can't use them anyway
            do {
                try self.keychain.remove(Config.keychainUserEmailKey)
                try self.keychain.remove(Config.keychainUserIdKey)
                try self.keychain.remove(Config.keychainUserPasswordKey)
            } catch _ {}
            self.logout()
        }

        return self.hasCredentials()
    }

    /**
    Try to save the credentials to the keychain

    :returns: whether or not the operation succeeded
    */
    public func tryKeychainDataSet() -> Bool {
        do {
            try self.keychain.set(self.password!, key: Config.keychainUserPasswordKey)
            try self.keychain.set(self.email!, key: Config.keychainUserEmailKey)
            try self.keychain.set(self.userId!, key: Config.keychainUserIdKey)
        } catch _ {
            return false
        }

        // TODO: error handling!
        return true
    }

    /**
    Try to get the user id by email.

    :param: callback closure (Bool, String)
    */
    public func tryIdFetch(callback: (Bool, String) -> ()) -> Void {
        if let mail = self.email, let password = self.password {

            Networking.getIdForEmail(mail,
                password: password,
                callback: { (returnedJson, error) -> Void in

                    if (error != nil) {
                        if error!.code == 404 || error!.code == 401 {
                            callback(false, error!.userInfo["message"] as! String)
                            
                        } else if let json = returnedJson {
                            callback(false, json["message"].string!)

                        } else {
                            // we are probably offline!
                            callback(false, "Code1")
                        }

                    } else {
                        if let json = returnedJson {
                            self.userId = json["_id"].string!

                            if let id = self.userId {
                                self.tryKeychainDataSet()
                                callback(true, id)

                            } else {
                                callback(false, json["message"].string!)
                            }

                        } else {
                            callback(false, "An unknown error occured. Code: 2\n")
                        }
                    }
            })

        } else {
            callback(false, "No credentials given.\n")
        }

    }

    /**
    Upload file to idrop.link

    :param: file absolute path to the file
    :param: callback closure (Bool, String)
    */
    public func uploadDrop(file: String!, callback: (Bool, String) -> ()) -> Void {
        if let tok = self.token, let id = self.userId {

            Networking.initializeDrop(userId,
                token: token,
                callback: { (returnedJson, error) -> Void in

                    if let json = returnedJson {
                        if let url = json["url"].string {
                            // copy url to pasteboard
                            let pasteBoard = NSPasteboard.generalPasteboard()
                            pasteBoard.clearContents()
                            pasteBoard.writeObjects([url])

                            Networking.uploadToDrop(id, token: tok,
                                dropId: json["_id"].string!,
                                filepath: file,
                                callback: { (returnedJson, error) -> Void in
                                    if let json = returnedJson {
                                        if let _ = self.userId {
                                            self.syncDrops()
                                            callback(true, "?")

                                        } else {
                                            callback(false, json["message"].string!)
                                        }

                                    } else {
                                        callback(false, "An unknown error occured.\n")
                                    }
                                }, onProgress: {(progress) -> Void in
                                    self.onProgress(progress)
                            })

                        } else {
                            // enforce normal icon
                            self.onProgress(100.0)

                            if let msg = json["message"].string {
                                callback(false, msg)
                            } else {
                                callback(false, "An unknown error occured.\n")
                            }
                        }

                    } else {
                        // enforce normal icon
                        self.onProgress(100.0)
                        callback(false, "No data returned")
                    }
            })
        }

    }

    /**
    This function fetches all drops by the user and prepares them (date etc.).
    */
    public func syncDrops() {
        if let _ = self.token, let _ = self.userId {
            Networking.getDrops(userId,
                token: token,
                callback: { (returnedJson, error) -> Void in
                    if let json = returnedJson {
                        if let drops = json["drops"].array {
                            // this formatter is used to match the string
                            // and create a NSDate
                            let inDateFormatter = NSDateFormatter()
                            inDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            inDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)

                            // this formatter is used to produce the displayed string
                            // in the wanted format
                            let outDateFormatter = NSDateFormatter()
                            outDateFormatter.doesRelativeDateFormatting = true
                            outDateFormatter.setLocalizedDateFormatFromTemplate("HH:mm dd/MM/yyyy")

                            for d in drops {
                                // we need to check for failed drops
                                // they have no name (but an id, but we want to be
                                // really sure, same with url, that they exist)
                                let name = d["name"].string
                                let url = d["url"].string
                                let _id = d["_id"].string

                                if let _name = name, _url = url, _ = _id {
                                    var formattedDate: String? = nil

                                    // parse the incoming date to a string
                                    // in a format we want it to display
                                    if let date = d["upload_date"].string {
                                        // get NSDate for string
                                        let theDate = inDateFormatter.dateFromString(date)
                                        
                                        if let theD = theDate {
                                            // get string for NSDate
                                            formattedDate = outDateFormatter.stringFromDate(theD)
                                        }
                                    }

                                    // if no date could be matched by the procedure above
                                    // we fall back to the given date
                                    formattedDate = formattedDate != nil ? formattedDate : d["upload_date"].string
                                    
                                    let drop = Drop(dropDate: formattedDate,
                                        name: _name,
                                        _id: _id,
                                        url: _url,
                                        shortId: d["shortId"].string,
                                        type: d["type"].string,
                                        path: d["path"].string,
                                        views: d["views"].string)

                                    // we want the drops to be ordered by the newest,
                                    // thus the last in list. we don't want to sort
                                    // afterwards, thus we prepend the drop to the
                                    // list.

                                    // note that insert(x,y) and append(x)
                                    // have the same complexicity.
                                    self.drops.insert(drop, atIndex: 0)

                                } else {
                                    // this might not have failed yet but rather
                                    // is being uploaded. but we could
                                    // implement some cleaning up here
                                    print("found failed drop")
                                }
                            }
                        }
                    }
            })
        }
    }
    
}
