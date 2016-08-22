//
//  FlickrPhotoStorage.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/20/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import Foundation

class FlickrPhotoStorage {
    private var flickrPhotos:[NSIndexPath:FlickrPhoto] = [:]
    
    func getPhotoAtIndexPath(indexPath:NSIndexPath) -> FlickrPhoto? {
        return flickrPhotos[indexPath]
    }
    
    func removePhotoAtIndexPath(indexPath:NSIndexPath) {
        return flickrPhotos[indexPath] = nil
    }
    
    func addPhoto(photo:FlickrPhoto, indexPath:NSIndexPath) {
        flickrPhotos[indexPath] = photo
    }
    
    func allPhotos () -> [NSIndexPath:FlickrPhoto] {
        return flickrPhotos
    }
    
    func clearAllPhotos () {
        flickrPhotos.removeAll()
    }
}