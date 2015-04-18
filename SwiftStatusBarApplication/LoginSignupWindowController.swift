//
//  LoginSignupWindowController.swift
//  SwiftStatusBarApplication
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

    @IBAction func showLoginSheet(sender: AnyObject) {
        _window.beginSheet(loginSheet, completionHandler: nil)
    }
    
    @IBAction func closeLoginSheet(sender: AnyObject) {
        _window.endSheet(_window)
        loginSheet.orderOut(sender)
    }
    
    @IBAction func showSignupSheet(sender: AnyObject) {
        _window.beginSheet(signupSheet, completionHandler: nil)
    }
    
    @IBAction func closeSignupSheet(sender: AnyObject) {
        _window.endSheet(_window)
        signupSheet.orderOut(sender)
    }
}