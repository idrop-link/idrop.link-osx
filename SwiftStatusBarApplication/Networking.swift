//
//  API.swift
//  SwiftStatusBarApplication
//
//  Created by Christian Schulze on 08/04/15.
//  Copyright (c) 2015 Christian Schulze. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
    This class provides an interface to the idrop.link backend API.
*/
final class Networking {
    
    /**
        Custom callback type alias
    */
    typealias APICallback = ((JSON?, NSError?) -> ())
    
    /**
        Creates a User with the given credentials

        @param email    The email address the user wants to use
        @param password The users password to identify
        @param callback Function to call with result or error when finished
    
        @warning The email can only be used once, hence it has to be
                 unique.
    */
    func createUser(email: String!, password: String!, callback: APICallback) {
        Alamofire
            .request(.POST, "\(Config.baseURL)/users", parameters: ["email":email, "password":password])
            .responseJSON { (request, response, jsonData, error) -> Void in
                let json = JSON(jsonData!)
                callback(json, error)
            }
    }

    /**
        Lookup a User by their ID
    
        @param id   The ID as returned by createUser or signIn
        
        @see createUser
        @see signIn
    */
    func getUser(id: String!, callback: APICallback) {
        Alamofire
            .request(.GET, "\(Config.baseURL)/users/\(id)")
            .responseJSON{ (request, response, jsonData, error ) -> Void in
                let json = JSON(jsonData!)
                callback(json, error)
            }
    }
}