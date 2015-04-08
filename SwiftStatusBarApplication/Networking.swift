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

// MARK: - AuthRouter enum
/**
Router for authentification based paths
*/
enum AuthRouter: URLRequestConvertible {
    static let baseUrlString = Config.baseURL
    static var authToken: String?
    
    case CreateUser([String: AnyObject])
    case DeleteUser(String)
    case GetUser(String)
    case UpdateUser(String, [String: AnyObject])
    
    // MARK: Methods
    var method: Alamofire.Method {
        switch self {
        case .CreateUser:
            return .POST
        case .DeleteUser:
            return .DELETE
        case .GetUser:
            return .GET
        case .UpdateUser:
            return .PUT
        }
    }
    
    // MARK: Paths
    var path: String {
        switch self {
        case .CreateUser:
            return "/users"
        case .DeleteUser(let userId):
            return "/users/\(userId)"
        case .GetUser(let userId):
            return "/users/\(userId)"
        case .UpdateUser(let userId, _):
            return "/users/\(userId)"
        }
    }
    
    // MARK: URLRequestConvertible
    var URLRequest: NSURLRequest {
        let URL:NSURL! = NSURL(string: AuthRouter.baseUrlString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // set custom header
        if let token = AuthRouter.authToken {
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .CreateUser(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateUser(_, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}

// MARK: - Networking Class
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