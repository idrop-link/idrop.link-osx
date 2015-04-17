//
//  Keychain.swift
//  SwiftStatusBarApplication
//
//  Created by Christian Schulze on 17/04/15.
//  Copyright (c) 2015 CLAYTON MCILRATH. All rights reserved.
//  Source: https://swiftcast.tv/articles/dead-simple-keychain-access
//

import Foundation
import Security

public class Keychain {
    // MARK: - SET value
    /**
    Set value for key in keychain.
    
    :param: key the key to set
    :param: value the value for the key to be set
    
    :param: whether or not the value for key was set successfully
    */
    public class func set(key: String, value: String) -> Bool {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
            return set(key, value: data)
        }
        
        return false;
    }
    
    /**
    Set value for key in keychain.
    
    :param: key the key to set
    :param: value the value for the key to be set
    
    :param: whether or not the value for key was set successfully
    */
    public class func set(key: String, value: NSData) -> Bool {
        let query = [
            (kSecClass as! String): kSecClassGenericPassword,
            (kSecAttrAccount as! String): value,
            (kSecValueData as! String): key
        ]
        
        // remove old value if any
        SecItemDelete(query as CFDictionaryRef)
        
        // set new value, return true if no error occured
        // (means the new value is set)
        return SecItemAdd(query as CFDictionaryRef, nil) == noErr
    }
    
    // MARK: - GET value
    /**
    Get a value for a key
    
    :param: key key for the value to get
    
    :return: value or nil if no value for given key exists
    */
    public class func get(key: String) -> NSString? {
        if let data = getData(key) {
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        
        return nil
    }
    
    /**
    Get a value for a key as NSData
    
    :param: key key for the value to get
    
    :return: value or nil if no value for given key exists
    */
    public class func getData(key: String) -> NSData? {
        let query = [
            (kSecClass as! String)       : kSecClassGenericPassword,
            (kSecAttrAccount as! String) : key,
            (kSecReturnData as! String)  : kCFBooleanTrue,
            (kSecMatchLimit as! String)  : kSecMatchLimitOne
        ]
        
        var dataTypeRef: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == noErr && dataTypeRef != nil
        {
            return dataTypeRef!.takeRetainedValue() as? NSData
        }
        
        return nil
    }
    
    // MARK: - REMOVE key value pair
    /**
    Delete key value pair

    :param: key for key value pair to delete

    :return: whether or not the pair was deleted successfully
    */
    public class func delete(key: String) -> Bool {
        let query = [
            (kSecClass as! String)       : kSecClassGenericPassword,
            (kSecAttrAccount as! String) : key
        ]
        
        return SecItemDelete(query as CFDictionaryRef) == noErr
    }
    
    /**
    Clear value for key
    
    :param: key for value to clear
    
    :return: whether or not the value was cleared successfully
    */
    public class func clear() -> Bool {
        let query = [
            (kSecClass as String): kSecClassGenericPassword
        ]
        
        return SecItemDelete(query as CFDictionaryRef) == noErr
    }
}