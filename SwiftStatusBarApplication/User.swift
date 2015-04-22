//
//  User.swift
//  SwiftStatusBarApplication
//
//  Created by Christian Schulze on 17/04/15.
//  Copyright (c) 2015 Tommy Leung. All rights reserved.
//

import Foundation

public class User {
    var email: String?
    var password: String?
    var userId: String?

    /**
    Create new user
    
    :returns: user  id as returned by the api
    */
    public func createUser(email: String, password: String, callback: (Bool, String) -> ()) {
        Networking.createUser(email, password: password, callback: { (returnedJson, error) in
            if (error != nil) {
                print("error on createUser")
                if let json = returnedJson {
                    callback(false, json["message"].string!)
                } else {
                    callback(false, "no message returned")
                }
            } else {
                if let json = returnedJson {
                    self.email = email
                    self.password = password
                    self.userId = json["_id"].string
                    
                    if let id = self.userId {
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
    
    public init() {
        self.email = nil
        self.password = nil
        self.userId = nil
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
    }
}