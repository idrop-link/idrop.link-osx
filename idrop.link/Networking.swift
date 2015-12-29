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

// MARK: - Router enum
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

    :param: email the users email
    :param: password the users password

    :returns: URLRequestConvertible
    */
    case CreateUser(String, String)

    /**
    Creates request for deleting a user

    :param: userId  The ID as returned by createUser or signIn
    :param: token   The authentification token

    :returns: URLRequestConvertible
    */
    case DeleteUser(String, String)

    /**
    Creates request for getting a users info

    :param: userId  The ID as returned by createUser or signIn
    :param: token   The authentification token

    :returns: URLRequestConvertible
    */
    case GetUser(String, String)

    /**
    Creates request for updatig a users info

    :param: userId  The ID as returned by createUser or signIn
    :param: token   The authentification token
    :param: fields  The fields to be updated

    :returns: URLRequestConvertible
    */
    case UpdateUser(String, String, [String: AnyObject])

    /**
    Creates request for retrieving a authentification token

    :param: userId  The ID as returned by createUser or signIn
    :param: email   The users email
    :param: password The users password

    :returns: URLRequestConvertible
    */
    case GetAuthToken(String, String, String)

    /**
    Get user id for the email. (Needed for communicating with the api.

    :param: email   The users email
    :param: password The users password
    */
    case GetEmailForId(String, String)

    /**
    Register drop

    :param: userId  The ID as returned by createUser or signIn
    :param: token   The authentification token
    */
    case InitializeDrop(String, String)

    /**
    Upload file to registered drop

    :param: userId  The ID as returned by createUser or signIn
    :param: token   The authentification token
    :param: dropId  The ID as returned by InitializeDrop
    */
    case UploadFileToDrop(String, String, String)

    /**
    Get list of all drops

    :param: userId  The ID as returned by createUser or signIn
    :param: token   The authentification token

    :returns: URLRequestConvertible
    */
    case GetDrops(String, String)

    // MARK: Methods
    /**
    HTTP method for different kind of requests
    */
    var method: Alamofire.Method {
        switch self {
        case .CreateUser, .GetAuthToken, .GetEmailForId, InitializeDrop,
        UploadFileToDrop:
            return .POST
        case .DeleteUser:
            return .DELETE
        case .GetUser, .GetDrops:
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
    var URLRequest: NSMutableURLRequest {
        let URL:NSURL! = NSURL(string: Router.baseUrlString)
        let mutableURLRequest = NSMutableURLRequest(URL:
            URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        // MARK: Custom headers
        // Tokenized requests need a custom `Authorization` header with the token
        switch self {
        case .UpdateUser(_, let token, _):
            mutableURLRequest.setValue("\(token)",
                forHTTPHeaderField: "Authorization")

        case .GetUser(_, let token):
            mutableURLRequest.setValue("\(token)",
                forHTTPHeaderField: "Authorization")

        case .DeleteUser(_, let token):
            mutableURLRequest.setValue("\(token)",
                forHTTPHeaderField: "Authorization")

        case .InitializeDrop(_, let token):
            mutableURLRequest.setValue("\(token)",
                forHTTPHeaderField: "Authorization")

        case .UploadFileToDrop(_, let token, _):
            mutableURLRequest.setValue("\(token)",
                forHTTPHeaderField: "Authorization")

        case .GetDrops(_, let token):
            mutableURLRequest.setValue("\(token)",
                forHTTPHeaderField: "Authorization")

        default:
            break;
        }

        // MARK: Parameters
        switch self {
        case .CreateUser(let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest,
                parameters: ["email": email, "password": password]).0

        case .UpdateUser(_, _, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest,
                parameters: parameters).0

        case .GetAuthToken(_, let email, let password):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest,
                parameters: ["email": email, "password": password]).0

        case .GetEmailForId(let email, let password):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest,
                parameters: ["email": email, "password": password]).0

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
            .responseJSON { response in
                if let error = response.result.error {
                    callback(nil, error)
                } else if let json = response.result.value {
                    callback(JSON(json), nil)
                } else {
                    callback(nil, nil)
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
            .responseJSON{ response in
                if let error = response.result.error {
                    callback(nil, error)
                } else if let json = response.result.value {
                    callback(JSON(json), nil)
                } else {
                    callback(nil, nil)
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
    class func getToken(userId: String!, email: String!, password: String!,
        callback: APICallback) {
            Alamofire
                .request(Router.GetAuthToken(userId, email, password))
                .responseJSON { response in
                    // callback(nil, NSError(domain: "Networking", code: 404, userInfo: ["message": "There is no user with this email address."]))
                    if let error = response.result.error {
                        callback(nil, error)
                    } else if let json = response.result.value {
                        callback(JSON(json), nil)
                    } else {
                        callback(nil, nil)
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
            .responseJSON { response in
                // callback(nil, NSError(domain: "Networking", code: 404, userInfo: ["message": "There is no user with this email address.\n"]))
                // callback(nil, NSError(domain: "Networking", code: 401, userInfo: ["message": "Wrong email/password.\n"]))
                if let error = response.result.error {
                    callback(nil, error)
                } else if let json = response.result.value {
                    callback(JSON(json), nil)
                } else {
                    callback(nil, nil)
                }
        }
    }

    /**
    Initialize the drop by registering a drop

    :param: userId  The ID as returned by createUser or signIn
    :param: token   A valid access token
    :param: callback Function to call with result or error when finished
    */
    class func initializeDrop(userId: String!, token: String!, callback: APICallback) {
        Alamofire
            .request(Router.InitializeDrop(userId, token))
            .responseJSON { response in
                if let error = response.result.error {
                    callback(nil, error)
                } else if let json = response.result.value {
                    callback(JSON(json), nil)
                } else {
                    callback(nil, nil)
                }
        }
    }

    /**
    Upload file to registered drop

    :param: userId  The ID as returned by createUser or signIn
    :param: token   A valid access token
    :param: dropId  The ID as returned by initializeDrop
    :param: callback Function to call with result or error when finished
    :param: onProgress  Optional function that gets called while uploading
    */
    class func uploadToDrop(userId: String!, token: String!, dropId: String!,
        filepath: String!, callback: APICallback, onProgress: ((Float) -> Void)?) {
            let url:NSURL = NSURL(string:
                filepath.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!)!
            let filename = url.lastPathComponent
            let fileData = NSData(contentsOfFile: filepath)

            if !(fileData != nil) {
                callback(nil, nil)
                return
            }

            let route = Router.UploadFileToDrop(userId, token, dropId)
            let request = route.URLRequest.mutableCopy() as! NSMutableURLRequest

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
            parameters
                .appendData("\r\n--\(boundary)--\r\n"
                    .dataUsingEncoding(NSUTF8StringEncoding)!)

            Alamofire
                .upload(request, data: parameters)
                .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    if let fn = onProgress {
                        fn(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                    }
                }
                .responseJSON { response in
                    if let error = response.result.error {
                        callback(nil, error)
                    } else if let json = response.result.value {
                        callback(JSON(json), nil)
                    } else {
                        callback(nil, nil)
                    }
            }
    }

    /**
    Get all drops of a user

    :param: userId  The ID as returned by createUser or signIn
    :param: token   A valid access token
    :param: callback Function to call with result or error when finished

    :see: getToken
    */
    class func getDrops(userId: String!, token: String!, callback: APICallback) {
        Alamofire
            .request(Router.GetDrops(userId, token))
            .responseJSON{ response in
                if let error = response.result.error {
                    callback(nil, error)
                } else if let json = response.result.value {
                    callback(JSON(json), nil)
                } else {
                    callback(nil, nil)
                }
        }
    }

}
