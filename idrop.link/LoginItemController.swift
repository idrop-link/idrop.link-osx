//
//  LoginItemController.swift
//  idrop.link
//
//  Created by Erica Sadun on 4/1/15.
//  Modified by Christian Schulze on 28/09/15.
//
//  Copyright (c) 2015 Erica Sadun. All rights reserved.
//
//  Licensed under BSD License according to
//   http://ericasadun.com/2015/04/01/swift-launch-at-login/
//
// Copyright © 2015 Erica Sadun. All Rights Reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// 3. The name of the author may not be used to endorse or promote products
// derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Erica Sadun "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
// EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation

class LoginItemController: NSObject {

    static func getLoginItems() -> LSSharedFileList? {
        let allocator : CFAllocator! = CFAllocatorGetDefault().takeUnretainedValue()
        let kLoginItems : CFString! = kLSSharedFileListSessionLoginItems.takeUnretainedValue()
        var loginItems_ = LSSharedFileListCreate(allocator, kLoginItems, nil)
        if loginItems_ == nil {return nil}
        let loginItems : LSSharedFileList! = loginItems_.takeRetainedValue()
        return loginItems
    }

    static func existingItem(itemURL: NSURL) -> LSSharedFileListItem? {
        let loginItems_ = getLoginItems()
        if loginItems_ == nil {return nil}
        let loginItems = loginItems_!

        var seed : UInt32 = 0
        let currentItems = LSSharedFileListCopySnapshot(loginItems, &seed).takeRetainedValue() as NSArray

        for item in currentItems {
            let resolutionFlags : UInt32 = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
            var url = LSSharedFileListItemCopyResolvedURL(item as! LSSharedFileListItem, resolutionFlags, nil).takeRetainedValue() as NSURL
            if url.isEqual(itemURL) {
                let result = item as! LSSharedFileListItem
                return result
            }
        }

        return nil
    }

    static func willLaunchAtLogin(itemURL: NSURL) -> Bool {
        return existingItem(itemURL) != nil
    }

    static func setLaunchAtLogin(itemURL: NSURL, enabled: Bool) -> Bool {
        let loginItems_ = getLoginItems()
        if loginItems_ == nil {return false}
        let loginItems = loginItems_!

        var item = existingItem(itemURL)
        if item != nil && enabled {return true}
        if item != nil && !enabled {
            LSSharedFileListItemRemove(loginItems, item)
            return true
        }
        
        LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst.takeUnretainedValue(), nil, nil, itemURL as CFURL, nil, nil)
        return true
    }

}
