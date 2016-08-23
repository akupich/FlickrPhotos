//
//  URLBuilder.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/23/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

class URLBuilder {
    class func remoteFlickrURL(withId strId:String) -> NSURL {
        return NSURL (string: "\(Constants.flickrServerURL)/\(Int(Constants.defaultPhotoSize.width))/\(Int(Constants.defaultPhotoSize.height))/\(strId)")!
    }
    
    class func remoteFlickrURL(withId strId:String, size:CGSize) -> NSURL {
        return NSURL(string: "\(Constants.flickrServerURL)/\(Int(size.width))/\(Int(size.height))/\(strId)")!
    }
    
    class func localFlickrURL (withId strId:String) -> NSURL {
        return TemporaryFileManager.sharedInstance.temporaryDirectoryURL.URLByAppendingPathComponent(strId + Constants.fpImageExtension)
    }
}