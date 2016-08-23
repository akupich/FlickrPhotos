//
//  PhotoOperations.swift
//  ClassicPhotos
//
//  Created by Andriy Kupich on 8/19/16.
//  Copyright © 2016 raywenderlich. All rights reserved.
//

import UIKit

enum FlickrPhotoState {
    case New, Downloaded, Failed
}

class PendingOperations {
    lazy var downloadsInProgress:[NSIndexPath: NSOperation] = [:]
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
}

class ImageDownloader: NSOperation {
    let flickrPhoto: FlickrPhoto
    let indexPath: NSIndexPath
    let imageSize: CGSize?
    
    init(flickrPhoto: FlickrPhoto, indexPath: NSIndexPath, imageSize: CGSize? = nil) {
        self.flickrPhoto = flickrPhoto
        self.indexPath = indexPath
        self.imageSize = imageSize
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        if let size = imageSize {
            flickrPhoto.url = URLBuilder.remoteFlickrURL(withId: "\(indexPath.row)", size: size)
        }
        let imageData = FlickrPhotosAPI.remoteImageSyncForFlickrPhoto(flickrPhoto)
        
        if self.cancelled {
            return
        }
        
        if let data = imageData where UIImage(data: data) != nil {
            self.flickrPhoto.state = .Downloaded
        } else {
            self.flickrPhoto.state = .Failed
        }
        
        FlickrPhotosAPI.sharedInstance.saveFlickrPhoto(flickrPhoto, withImageData: imageData, indexPath: indexPath)
    }
    
}