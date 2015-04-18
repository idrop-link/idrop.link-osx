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
enum Router: URLRequestConvertible {
    static let baseUrlString = Config.baseUrl
    static var authToken: String?
    
    case CreateUser(String, String)
    case DeleteUser(String)
    case GetUser(String)
    case UpdateUser(String, [String: AnyObject])
    
    // MARK: Methods
    /**
    HTTP method for different kind of requests
    */
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
    /**
    Defines the API routes to call for a specific request
    */
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
    
    /**
    Defines wether or not the request needs a token for the request
    */
    var tokenizedRequest: Bool {
        switch self {
        case .CreateUser:
            return false
        case .DeleteUser, .GetUser, .UpdateUser:
            return true
        }
    }
    
    // MARK: URLRequestConvertible
    var URLRequest: NSURLRequest {
        let URL:NSURL! = NSURL(string: Router.baseUrlString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // set custom header
        // for unauthenticated requests the token should be nil anyway
        if let token = Router.authToken {
            if (tokenizedRequest) {
                mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        switch self {
        case .CreateUser(let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["email": email, "password": password]).0
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
    
    :param: email    The email address the user wants to use
    :param: password The users password to identify
    :param: callback Function to call with result or error when finished
    
    :warning: The email can only be used once, hence it has to be
    unique.
    */
    class func createUser(email: String, password: String, callback: APICallback) {
        Alamofire
            .request(Router.CreateUser(email, password))
            .responseJSON { (request, response, jsonData, error) -> Void in
                if let data: AnyObject = jsonData {
                    let json = JSON(data)
                    callback(json, error)
                } else {
                    callback(nil, error)
                }
        }
    }
    
    /**
    Lookup a User by their ID
    
    :param: id      The ID as returned by createUser or signIn
    :param: token   A valid access token
    
    :see: createUser
    :see: getToken
    */
    class func getUser(id: String!, token: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetUser(id))
            .responseJSON{ (request, response, jsonData, error ) -> Void in
                let json = JSON(jsonData!)
                callback(json, error)
        }
    }
    
    /**
    Get access toke for a user
    
    :param: email       The users email address
    :param: password    The users password
    :param: id          The users id as returned by singup
    
    :see: createUser
    */
    class func getToken(email: String!, password: String!, userId: String!, callback: APICallback) {
//        Alamofire
//            .request(Router.GetAuthToken(email, password))
//            .responseJSON { (request, response, jsonData, error) -> Void in
//                let json = JSON(jsonData!)
//                callback(json, error)
//        }
    }
}