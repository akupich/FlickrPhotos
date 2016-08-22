//
//  FlickrPhoto.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/20/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

class FlickrPhoto {
    var title:String
    var url:NSURL
    var ID:String
    
    var localImageUrl:NSURL?
    var state = FlickrPhotoState.New
    
    var image: UIImage?
    
    init(title:String, url:NSURL, ID:String) {
        self.ID = ID
        self.title = title
        self.url = url
    }
}