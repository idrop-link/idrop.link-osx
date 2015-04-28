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
    
    var keychain: Keychain
    
    // MARK: - Initializers
    public init() {
        self.email = nil
        self.password = nil
        self.userId = nil
        self.keychain = Keychain(service: Config.keychainServiceEntity)
    }
    
    /**
    Initialize user with credentials (from keychain or similar)
    
    :param: email       the users email
    :param: password    the users password
    :param: userId      the users id as returned by the api
    
    :return: new user object
    */
    public init(email: String, password: String, userId: String) {
        self.email = email
        self.password = password
        self.userId = userId
        self.keychain = Keychain(service: Config.keychainServiceEntity)
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
        Networking.getToken(self.userId, email: self.email, password: self.password, callback: { (returnedJson, error) in
            if (error != nil) {
                if let json = returnedJson {
                    callback(false, json["message"].string!)
                } else {
                    // the user does not exist anymore, so we can delete all
                    // saved credentials
                    if error!.code == 404 {
                        self.keychain.removeAll()
                        callback(false, "A user for this email does not exist.")

                    } else if error!.code == 400 || error!.code == 401 {
                        self.keychain.removeAll()
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
                        callback(true, self.token!)

                    } else {
                        callback(false, "An error occuroed.")
                    }

                } else {
                    callback(false, "An error occured.")
                }
            }
        })
    }
    
    /**
    Try to get access token if we have the credentials

    :see: login
    */
    public func tryLogin() {
        if (self.hasCredentials()) {
            self.login({ (success, msg) in
                if (success) {
                    print("success with token \(msg)\n")
                } else {
                    print("error: \(msg)")
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
        var mail = self.keychain.get(Config.keychainUserEmailKey)
        var pass = self.keychain.get(Config.keychainUserEmailKey)
        var id = self.keychain.get(Config.keychainUserIdKey)
        
        if (mail != nil && pass != nil && id != nil) {
            self.setCredentials(mail, password: pass, id: id)
        } else {
            // try to remove the keys if the credential set is incomplete 
            // we can't use them anyway
            self.keychain.remove(Config.keychainUserEmailKey)
            self.keychain.remove(Config.keychainUserIdKey)
            self.keychain.remove(Config.keychainUserPasswordKey)
        }
        
        return self.hasCredentials()
    }
    
    /*
    Try to save the credentials to the keychain
    
    :returns: whether or not the operation succeeded
    */
    public func tryKeychainDataSet() -> Bool {
        self.keychain.set(self.password!, key: Config.keychainUserPasswordKey)
        self.keychain.set(self.email!, key: Config.keychainUserEmailKey)
        self.keychain.set(self.userId!, key: Config.keychainUserIdKey)
        
        // TODO: error handling!
        return true
    }
    
    /**
    Try to get the user id by email.

    :param: callback closure (Bool, String)
    */
    public func tryIdFetch(callback: (Bool, String) -> ()) -> Void {
        if let mail = self.email, let password = self.password {
            Networking.getIdForEmail(mail, password: password, callback: { (returnedJson, error) -> Void in
                if (error != nil) {
                    if error!.code == 404 || error!.code == 401 {
                        callback(false, error!.userInfo!["message"] as! String)

                    } else if let json = returnedJson {
                        callback(false, json["message"].string!)

                    } else {
                        callback(false, "An unknown error occured. Code: 1\n")
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
}