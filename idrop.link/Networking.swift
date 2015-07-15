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

We need a router because of the custom header `Authorization`
that contains the token (if needed) which we want so send along with.
That very method for custom http headers is advised by Alamofire.

:see: https://github.com/Alamofire/Alamofire#crud--authorization
*/
enum Router: URLRequestConvertible {
    static let baseUrlString = Config.apiUrl
    
    /**
    Creates request for creating a user
    
    - parameter email: the users email
    - parameter password: the users password
    
    - returns: URLRequestConvertible
    */
    case CreateUser(String, String)
    
    /**
    Creates request for deleting a user
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   The authentification token
    
    - returns: URLRequestConvertible
    */
    case DeleteUser(String, String)
    
    /**
    Creates request for getting a users info
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   The authentification token
    
    - returns: URLRequestConvertible
    */
    case GetUser(String, String)
    
    /**
    Creates request for updatig a users info
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   The authentification token
    - parameter fields:  The fields to be updated
    
    - returns: URLRequestConvertible
    */
    case UpdateUser(String, String, [String: AnyObject])
    
    /**
    Creates request for retrieving a authentification token
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter email:   The users email
    - parameter password: The users password
    
    - returns: URLRequestConvertible
    */
    case GetAuthToken(String, String, String)
    
    /**
    Get user id for the email. (Needed for communicating with the api.
    
    - parameter email:   The users email
    - parameter password: The users password
    */
    case GetEmailForId(String, String)
    
    /**
    Register drop
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   The authentification token
    */
    case InitializeDrop(String, String)
    
    /**
    Upload file to registered drop
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   The authentification token
    - parameter dropId:  The ID as returned by InitializeDrop
    */
    case UploadFileToDrop(String, String, String)
    
    /**
    Get list of all drops
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   The authentification token
    
    - returns: URLRequestConvertible
    */
    case GetDrops(String, String)
    
    // MARK: Methods
    /**
    HTTP method for different kind of requests
    */
    var method: Alamofire.Method {
        switch self {
        case .CreateUser, .GetAuthToken, InitializeDrop, UploadFileToDrop:
            return .POST
        case .DeleteUser:
            return .DELETE
        case .GetUser, .GetEmailForId, .GetDrops:
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
        case .InitializeDrop(let userId, _):
            return "/users/\(userId)/drops"
        case .UploadFileToDrop(let userId, _, let dropId):
            return "/users/\(userId)/drops/\(dropId)"
        case .GetDrops(let userId, _):
            return "/users/\(userId)/drops/"
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
        case .InitializeDrop(_, let token):
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        case .UploadFileToDrop(_, let token, _):
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        case .GetDrops(_, let token):
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "Authorization")
        default:
            break;
        }
        
        // MARK: Parameters
        switch self {
        case .CreateUser(let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["email": email, "password": password]).0
        case .UpdateUser(_, _, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .GetAuthToken(_, let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["email": email, "password": password]).0
        case .GetEmailForId(let email, let password):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["email": email, "password": password]).0
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
    
    - parameter email:    The email address the user wants to use
    - parameter password: The users password to identify
    - parameter callback: Function to call with result or error when finished
    
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
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   A valid access token
    - parameter callback: Function to call with result or error when finished
    
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
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter email:       The users email address
    - parameter password:    The users password
    - parameter callback: Function to call with result or error when finished
    
    :see: createUser
    */
    class func getToken(userId: String!, email: String!, password: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetAuthToken(userId, email, password))
            .responseJSON { (request, response, jsonData, error) -> Void in
                if (response?.statusCode == 404) {
                    callback(nil, NSError(domain: "Networking", code: 404, userInfo: ["message": "There is no user with this email address."]))
                } else if let data: AnyObject = jsonData {
                    let json = JSON(data)
                    callback(json, error)
                } else {
                    callback(nil, error)
                }
        }
    }
    
    /**
    Get users id for email to communicate with the api.
    
    - parameter email:       The users email address
    - parameter password:    The users password
    - parameter callback: Function to call with result or error when finished
    */
    class func getIdForEmail(email: String!, password: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetEmailForId(email, password))
            .responseJSON { (request, response, jsonData, error) -> Void in
                if (response?.statusCode == 404) {
                    callback(nil, NSError(domain: "Networking", code: 404, userInfo: ["message": "There is no user with this email address.\n"]))
                } else if response?.statusCode == 401 {
                    callback(nil, NSError(domain: "Networking", code: 401, userInfo: ["message": "Wrong email/password.\n"]))
                } else if let data: AnyObject = jsonData {
                    let json = JSON(data)
                    callback(json, error)
                } else {
                    callback(nil, error)
                }
        }
    }
    
    /**
    Initialize the drop by registering a drop
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   A valid access token
    - parameter callback: Function to call with result or error when finished
    */
    class func initializeDrop(userId: String!, token: String!, callback: APICallback) {
        Alamofire
            .request(Router.InitializeDrop(userId, token))
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
    Upload file to registered drop
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   A valid access token
    - parameter dropId:  The ID as returned by initializeDrop
    - parameter callback: Function to call with result or error when finished
    - parameter onProgress:  Optional function that gets called while uploading 
    */
    class func uploadToDrop(userId: String!, token: String!, dropId: String!, filepath: String!, callback: APICallback, onProgress: ((Float) -> Void)?) {
        let url:NSURL = NSURL(string: filepath.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!)!
        let filename = url.path!.lastPathComponent
        let fileData = NSData(contentsOfFile: filepath)

        if !(fileData != nil) {
            callback(nil, nil)
            return
        }
        
        var route = Router.UploadFileToDrop(userId, token, dropId)
        var request = route.URLRequest.mutableCopy() as! NSMutableURLRequest
        
        let boundary = "NET-POST-boundary-\(arc4random())-\(arc4random())"
        request.setValue("multipart/form-data;boundary="+boundary,
            forHTTPHeaderField: "Content-Type")
        
        let parameters = NSMutableData()
        
        // append content disposition
        parameters.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        parameters.appendData("Content-Disposition: form-data; name=\"data\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // append content type
        parameters.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        parameters.appendData(fileData!)
        parameters.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        Alamofire
            .upload(request, parameters)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                if let fn = onProgress {
                    fn(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                }
            }
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
    Get all drops of a user
    
    - parameter userId:  The ID as returned by createUser or signIn
    - parameter token:   A valid access token
    - parameter callback: Function to call with result or error when finished
    
    :see: getToken
    */
    class func getDrops(userId: String!, token: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetDrops(userId, token))
            .responseJSON{ (request, response, jsonData, error ) -> Void in
                if let data: AnyObject = jsonData {
                    let json = JSON(data)
                    callback(json, error)
                } else {
                    callback(nil, error)
                }
        }
    }
}
