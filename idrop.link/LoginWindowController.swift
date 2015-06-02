//
//  Login.swift
//  idrop.link
//
//  Created by Christian Schulze on 28/04/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

/**
WindowController for the Login window.
*/
class LoginWindowController: NSWindowController {
    @IBOutlet var _window: NSWindow!

    @IBOutlet weak var loginEmail: NSTextField!
    @IBOutlet weak var loginPassword: NSTextField!
    @IBOutlet weak var loginButton: NSButton!

    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet var errorSheet: NSPanel!
    @IBOutlet weak var errorSheetText: NSTextField!

    var user: User?

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    /**
    Open a sheet displaying an error message

    :param: message description of the error
    */
    func showErrorSheetWithMessage(message: String) {
        errorSheetText.stringValue = message
        _window.beginSheet(errorSheet, completionHandler: nil)
    }

    @IBAction func doLogin(sender: AnyObject) {
        var finishLogin = { () -> Void in
            self.spinner.stopAnimation(sender)
            self.loginButton.enabled = true
            self._window.orderOut(sender)
            Notification.showNotification("idrop.link", subtitle: "You are logged in.")
            return
        }

        var finishLoginWithError = { (msg: String) -> Void in
            self.spinner.stopAnimation(sender)
            self.loginButton.enabled = true
            self.showErrorSheetWithMessage(msg)
            return
        }

        spinner.startAnimation(sender)
        self.loginButton.enabled = false

        if let usr = self.user {
            usr.email = loginEmail.stringValue
            usr.password = loginPassword.stringValue
            
            usr.tryIdFetch({ (success, msg) -> Void in
                if usr.hasCredentials() {
                    usr.login({ (success, msg) -> Void in
                        if !success {
                            finishLoginWithError(msg)
                        } else {
                            finishLogin()
                        }
                    })
                } else {
                    if (msg == "Code1") {
                        finishLoginWithError("No connection could be established.\nCheck your internet connection and try again.\n")
                    } else {
                        finishLoginWithError(msg)
                    }
                }
            })
        } else {
            finishLoginWithError("An unknown error occured.")
        }
    }

    @IBAction func closeErrorSheet(sender: AnyObject) {
        _window.endSheet(_window)
        errorSheet.orderOut(sender)
    }

}
