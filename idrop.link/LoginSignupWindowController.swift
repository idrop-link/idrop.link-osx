//
//  LoginSignupWindowController.swift
//  idrop.link
//
//  Created by Christian Schulze on 18/04/15.
//  Copyright (c) 2015 Christian Schulze. All rights reserved.
//

import Foundation
import Cocoa

class LoginSignupWindowController: NSWindowController {
    @IBOutlet var _window: NSWindow!
    @IBOutlet var loginSheet: NSPanel!
    @IBOutlet var signupSheet: NSPanel!
    
    @IBOutlet weak var signupEmail: NSTextField!
    @IBOutlet weak var signupPassword: NSTextField!
    
    @IBOutlet weak var loginEmail: NSTextField!
    @IBOutlet weak var loginPassword: NSTextField!
    
    var user: User?
    
    // MARK: - Login
    @IBAction func showLoginSheet(sender: AnyObject) {
        _window.beginSheet(loginSheet, completionHandler: nil)
    }
    
    @IBAction func doLogin(sender: AnyObject) {
        print("do login\n")
        if let usr = self.user {
            usr.tryIdFetch({ (success, msg) -> Void in
                if usr.hasCredentials() {
                    usr.tryLogin()
                    self.closeLoginSheet(sender)
                }
            })
        }
    }
    
    @IBAction func closeLoginSheet(sender: AnyObject) {
        _window.endSheet(_window)
        loginSheet.orderOut(sender)
    }
    
    // MARK: - Signup
    @IBAction func showSignupSheet(sender: AnyObject) {
        _window.beginSheet(signupSheet, completionHandler: nil)
    }
    
    @IBAction func doSignup(sender: AnyObject) {
        print("do signup\n")
        if let usr = self.user {
            usr.createUser(self.signupEmail.stringValue, password: self.signupPassword.stringValue, callback: { (success, msg) in
                if (success) {
                    usr.tryLogin()
                    self.closeSignupSheet(self)
                } else {
                    // TODO: error handling in the UI
                    print("\(msg)\n")
                }
            })
        } else {
            print("fuck, no user\n")
        }
    }
    
    @IBAction func closeSignupSheet(sender: AnyObject) {
        _window.endSheet(_window)
        signupSheet.orderOut(sender)
    }
}