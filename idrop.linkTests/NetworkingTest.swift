//
//  NetworkingTest.swift
//  idrop.link
//
//  Created by Christian Schulze on 27/04/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa
import XCTest

class NetworkingTest: XCTestCase {
    var token:String?
    var userId:String?
    var email = "foo@b354ar.com"
    var password = "sweetjezus"
    
    func testCreateUser() {
        let readyExpectation = expectationWithDescription("ready")
        
        Networking.createUser(self.email, password: self.password, callback: { (returnedJson, error) -> Void in
            XCTAssertNil(error, "error should not be nil, was: \(error)")
            
            if let json = returnedJson {
                var id = json["_id"].string
                
                XCTAssertNotNil(id, "no id returned")
                
                self.userId = id
            } else {
                XCTFail("no json returned")
            }
            
            // done
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetIdForMail() {
        let readyExpectation = expectationWithDescription("ready")
        
        Networking.getIdForEmail(self.email, password: self.password, callback: { (returnedJson, error) -> Void in
            XCTAssertNil(error, "error should not be nil, was: \(error)")
            
            if let json = returnedJson {
                var id = json["_id"].string
                
                XCTAssertNotNil(id, "no id returned")
                XCTAssertNotNil(self.userId, "no id")
                XCTAssert(id == self.userId, "wrong or no id returned: \(id)")
            } else {
                XCTFail("no json returned")
            }
            
            // done
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetToken() {
        let readyExpectation = expectationWithDescription("ready")
        
        Networking.getToken(self.userId, email: self.email, password: self.password, callback: { (returnedJson, error) -> Void in
            XCTAssertNil(error, "error should not be nil, was: \(error)")
            
            if let json = returnedJson {
                var token:String! = json["token"].string
                
                XCTAssertNotNil(token, "no token returned")
                
                self.token = token
            } else {
                XCTFail("no json returned")
            }
            
            // done
            readyExpectation.fulfill()
            
        })
        
        waitForExpectationsWithTimeout(5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
}
