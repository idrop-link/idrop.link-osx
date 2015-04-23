//
//  User.swift
//  SwiftStatusBarApplication
//
//  Created by Christian Schulze on 17/04/15.
//  Copyright (c) 2015 Christian Schulze. All rights reserved.
//

import Foundation
import KeychainAccess

public class User {
    var email: String?
    var password: String?
    var userId: String?
    
    var keychain: Keychain
    
    /**
    Create new user
    
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
                        if let json = returnedJson {
                            callback(false, json["message"].string!)
                        } else {
                            callback(false, "no message or id returned")
                        }
                    }
                }
            }
        })
    }
    
    /*
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
}