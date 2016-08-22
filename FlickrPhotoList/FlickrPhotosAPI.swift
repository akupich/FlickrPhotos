//
//  FlickrPhotosAPI.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/20/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

class FlickrPhotosAPI: NSObject {
    private let flickrPhotosStorage: FlickrPhotoStorage
    
    static let sharedInstance = FlickrPhotosAPI()
    
    override init() {
        flickrPhotosStorage = FlickrPhotoStorage()
        
        super.init()
    }
    
    class func remoteImageSyncForFlickrPhoto (photo: FlickrPhoto, imageSize: CGSize? = nil) -> NSData? {
        print ("GET: \(photo.url.absoluteString)")
        return NSURLSession.requestSynchronousDataWithURLString(photo.url.absoluteString)
    }
    
    class func localImageAsyncForFlickrPhoto (flickrPhoto:FlickrPhoto, completion:(UIImage?)->()) {
        dispatch_user_initiated {
            if let url = flickrPhoto.localImageUrl {
                let image = TemporaryFileManager.sharedInstance.imageByURL(url)
                dispatch_main { completion(image) }
            } else {
                dispatch_main { completion(nil) }
            }
        }
    }
    
    func flickrPhotoAtIndexPath (indexPath: NSIndexPath) -> FlickrPhoto {
        if let flickrPhoto = flickrPhotosStorage.getPhotoAtIndexPath(indexPath) {
            return flickrPhoto
        } else {
            let urlStr = "\(Constants.flickrServerURL)/\(Int(Constants.defaultPhotoSize.width))/\(Int(Constants.defaultPhotoSize.height))/\(indexPath.row)"
            let flickrPhoto = FlickrPhoto (title: "\(indexPath.row)", url: NSURL(string: urlStr)!, ID: indexPath.toString())
            if TemporaryFileManager.sharedInstance.fileExistWithTitle(flickrPhoto.ID) {
                flickrPhoto.localImageUrl = TemporaryFileManager.sharedInstance.temporaryDirectoryURL.URLByAppendingPathComponent(flickrPhoto.ID + Constants.fpImageExtension)
                flickrPhoto.state = FlickrPhotoState.Downloaded
            }
            return flickrPhoto
        }
    }
    
    func removeFlickrPhoto (flickrPhoto:FlickrPhoto?) {
        if let indexPath = flickrPhoto?.ID.toIndexPath() {
            flickrPhotosStorage.removePhotoAtIndexPath(indexPath)
        }
    }
    
    func saveFlickrPhoto (photo: FlickrPhoto, withImageData imageData: NSData?, indexPath: NSIndexPath) {
        if let imageData = imageData {
            do {
                let storedUrl = try TemporaryFileManager.sharedInstance.writeSynchronousTemporaryFile(imageData, title: photo.ID + Constants.fpImageExtension)
                photo.localImageUrl = storedUrl
            } catch (let error) {
                print(error)
            }
        }
        
        flickrPhotosStorage.addPhoto(photo, indexPath: indexPath)
    }
    
    func saveFlickrPhoto (photo: FlickrPhoto, indexPath: NSIndexPath) {
        flickrPhotosStorage.addPhoto(photo, indexPath: indexPath)
    }
}