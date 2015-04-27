//
//  API.swift
//  idrop.link
//
//  Created by Christian Schulze on 08/04/15.
//  Copyright (c) 2015 Christian Schulze. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// MARK: - AuthRouter enum
/**
Router for authentification based paths.

The need for a routers is caused by our custom header `Authorization` 
that contains the token (if needed) which we want so send along with.
That very method for custom http headers is advised by Alamofire.

:see: https://github.com/Alamofire/Alamofire#crud--authorization
*/
enum Router: URLRequestConvertible {
    static let baseUrlString = Config.baseUrl

    /**
    Creates request for creating a user
    
    :param: email the users email
    :param: password the users password
    
    :returns: URLRequestConvertible
    */
    case CreateUser(String, String)

    /**
    Creates request for deleting a user
    
    :param: userId  The ID as returned by createUser or signIn
    :param: token   the authentification token
    
    :returns: URLRequestConvertible
    */
    case DeleteUser(String, String)

    /**
    Creates request for getting a users info
    
    :param: userId  The ID as returned by createUser or signIn
    :param: token   the authentification token
    
    :returns: URLRequestConvertible
    */
    case GetUser(String, String)

    /**
    Creates request for updatig a users info
    
    :param: userId  The ID as returned by createUser or signIn
    :param: token   the authentification token
    :param: fields  the fields to be updated
    
    :returns: URLRequestConvertible
    */
    case UpdateUser(String, String, [String: AnyObject])

    /**
    Creates request for retrieving a authentification token
    
    :param: userId  The ID as returned by createUser or signIn
    :param: email the users email
    :param: password the users password
    
    :returns: URLRequestConvertible
    */
    case GetAuthToken(String, String, String)
    
    /**
    Get user id for the email. (Needed for communicating with the api.

    :param: email the users email
    :param: password the users password
    */
    case GetEmailForId(String, String)

    // MARK: Methods
    /**
    HTTP method for different kind of requests
    */
    var method: Alamofire.Method {
        switch self {
        case .CreateUser, .GetAuthToken:
            return .POST
        case .DeleteUser:
            return .DELETE
        case .GetUser, .GetEmailForId:
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
        case .DeleteUser(let userId, _):
            return "/users/\(userId)"
        case .GetUser(let userId, _):
            return "/users/\(userId)"
        case .UpdateUser(let userId, _, _):
            return "/users/\(userId)"
        case .GetAuthToken(let userId, _, _):
            return "/users/\(userId)/authenticate"
        case .GetEmailForId(let email, _):
            return "/users/\(email)/idformail"
        }
    }
    
    // MARK: URLRequestConvertible
    var URLRequest: NSURLRequest {
        let URL:NSURL! = NSURL(string: Router.baseUrlString)
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // MARK: Custom headers
        // Tokenized requests need a custom `Authorization` header with the token
        switch self {
        case .UpdateUser(_, let token, _):
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        case .GetUser(_, let token):
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        case .DeleteUser(_, let token):
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
            
        default:
            break;
        }
        
        // MARK: Parameters
        switch self {
        case .CreateUser(let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["email": email, "password": password]).0
        case .UpdateUser(_, let token, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .GetAuthToken(_, let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["email": email, "password": password]).0
        case .GetEmailForId(let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["email": email, "password": password]).0
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
    
    :param: userId  The ID as returned by createUser or signIn
    :param: token   A valid access token
    :param: callback Function to call with result or error when finished
    
    :see: createUser
    :see: getToken
    */
    class func getUser(userId: String!, token: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetUser(userId, token))
            .responseJSON{ (request, response, jsonData, error ) -> Void in
                if let data: AnyObject = jsonData {
                    let json = JSON(data)
                    callback(json, error)
                } else {
                    callback(nil, error)
                }
        }
    }
    
    /**
    Get authentification token for a user
    
    :param: userId  The ID as returned by createUser or signIn
    :param: email       The users email address
    :param: password    The users password
    :param: callback Function to call with result or error when finished
    
    :see: createUser
    */
    class func getToken(userId: String!, email: String!, password: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetAuthToken(userId, email, password))
            .responseJSON { (request, response, jsonData, error) -> Void in
                if (response?.statusCode == 404) {
                    callback(nil, NSError(domain: "Networking", code: 404, userInfo: ["message": "no such user"]))
                }

                if let data: AnyObject = jsonData {
                    let json = JSON(data)
                    callback(json, error)
                } else {
                    callback(nil, error)
                }
        }
    }
    
    /**
    Get users id for email to communicate with the api.
    
    :param: email       The users email address
    :param: password    The users password
    :param: callback Function to call with result or error when finished
    */
    class func getIdForEmail(email: String!, password: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetEmailForId(email, password))
            .responseJSON { (request, response, jsonData, error) -> Void in
                if let data: AnyObject = jsonData {
                    let json = JSON(data)
                    callback(json, error)
                } else {
                    callback(nil, error)
                }
        }
    }
}