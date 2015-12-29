//
//  Login.swift
//  idrop.link
//
//  Created by Christian Schulze on 28/04/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa
import Quartz

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

        // Implement this method to handle any initialization after your window
        // controller's window has been loaded from its nib file.
    }

    /**
    Open a sheet displaying an error message

    - parameter message: description of the error
    */
    func showErrorSheetWithMessage(message: String) {
        errorSheetText.stringValue = message
        _window.beginSheet(errorSheet, completionHandler: nil)
    }

    func shakeWindow() {
        // config
        let numberOfShakes = 3
        let vigourOfShake: CGFloat = 0.05
        let durationOfShake: CFTimeInterval = 0.5

        let frame = self.window?.frame as NSRect!
        var shakePath: CGMutablePath = CGPathCreateMutable()

        CGPathMoveToPoint(shakePath, nil, NSMinX(frame), NSMinY(frame))

        for (var i = 0; i < numberOfShakes; i++) {
            CGPathAddLineToPoint(shakePath, nil,
                NSMinX(frame) - frame.size.width * vigourOfShake,
                NSMinY(frame))
            CGPathAddLineToPoint(shakePath, nil,
                NSMinX(frame) + frame.size.width * vigourOfShake,
                NSMinY(frame))
        }

        CGPathCloseSubpath(shakePath)
        let animation = CAKeyframeAnimation()
        animation.path = shakePath
        animation.duration = durationOfShake

        let dict = ["frameOrigin": animation]

        self.window?.animations = NSDictionary(dictionary: dict) as! [String : AnyObject]
        let animator = self.window?.animator()
        animator?.setFrameOrigin(frame.origin)
    }

    @IBAction func doLogin(sender: AnyObject) {
        let finishLogin = { () -> Void in
            self.spinner.stopAnimation(sender)
            self.loginButton.enabled = true
            self._window.orderOut(sender)
            Notification.showNotification("idrop.link", subtitle: "You are logged in.")
            return
        }

        let finishLoginWithError = { (msg: String) -> Void in
            self.spinner.stopAnimation(sender)
            self.loginButton.enabled = true
            self.shakeWindow()
            // self.showErrorSheetWithMessage(msg)
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
