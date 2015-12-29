//
//  Drop.swift
//  idrop.link
//
//  Created by Christian Schulze on 31/05/15.
//  Copyright (c) 2015 andinfinity. All rights reserved.
//

import Cocoa

class Drop: NSObject {
    var dropDate: String?
    var name: String?
    var _id: String?
    var url: String?
    var shortId: String?
    var type: String?
    var path: String?
    var views: Int?

    override init() {
        self.dropDate = nil
        self.name = nil
        self._id = nil
        self.url = nil
        self.shortId = nil
        self.type = nil
        self.path = nil
        self.views = nil
    }

    init(dropDate: String?, name: String?, _id: String?, url: String?,
        shortId: String?, type: String?, path: String?, views: String?) {
            self.dropDate = dropDate
            self.name = name
            self._id = _id
            self.url = url
            self.shortId = shortId
            self.type = type
            self.path = path
            if let _views = views {
                self.views = Int(_views)
            }
    }
}
