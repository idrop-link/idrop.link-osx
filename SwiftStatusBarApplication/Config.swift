//
//  Config.swift
//  SwiftStatusBarApplication
//
//  Created by Christian Schulze on 08/04/15.
//  Copyright (c) 2015 Tommy Leung. All rights reserved.
//

import Foundation

/**
    This structure provides mandatory configurations like secrets or API routes.
*/
struct Config {
    /**
        This is the base URL for the idrop.link API
    
        :warning: If you want do deploy a copy of idrop.link on your own you
                  have to edit this path to match your base link of your 
                  backend copy.
    */
    // static let baseUrl = "https://api.idrop.link/v1"
    static let baseUrl = "http://localhost:7667"
}