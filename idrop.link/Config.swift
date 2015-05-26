//
//  Config.swift
//  idrop.link
//
//  Created by Christian Schulze on 08/04/15.
//  Copyright (c) 2015 Christian Schulze. All rights reserved.
//

import Foundation

/**
    This structure provides mandatory configurations like secrets or API routes.
*/
struct Config {
    /**
        This is the base URL for the idrop.link API
    
        :warning: If you want do deploy a copy of idrop.link on your own you
                  have to edit this path to match your base link of your 
                  backend copy.
    */
    static let baseUrl = "http://www.idrop.link"
    static let apiUrl = "\(baseUrl)/api/v1"
    
    static let keychainServiceEntity = "de.andinfinity.idrop.link"
    static let keychainUserIdKey = "idrop-link-user-id"
    static let keychainUserEmailKey = "idrop-link-user-email"
    static let keychainUserPasswordKey = "idrop-link-user-password"
}