//
//  User.swift
//  SwiftStatusBarApplication
//
//  Created by Christian Schulze on 17/04/15.
//  Copyright (c) 2015 Tommy Leung. All rights reserved.
//

import Foundation

public class User {
    /**
    Create new user
    
    :returns: user id as returned by the api
    */
    public func createUser(email: String, password: String) -> Bool {
        Networking.createUser(email, password: password, callback: {(json, error) in
            if (error == nil) {
                // TODO: "return" nil
                print("error on createUser")
            } else {
                print(json)
            }
        })
        
        // TODO
        return true;
    }
}