//
//  PhotosDataSource.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/20/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

class PhotosDataSource : NSObject, UITableViewDelegate, UITableViewDataSource {
    var tableView:UITableView
    let pendingOperations = PendingOperations()
    
    init (tableView: UITableView) {
        self.tableView = tableView
        super.init()

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.photosCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("flickrPhotoCell", forIndexPath: indexPath) as! FlickrPhotoCell
        
        let flickrPhoto = FlickrPhotosAPI.sharedInstance.flickrPhotoAtIndexPath(indexPath)
        cell.updateWithFlickrPhoto(flickrPhoto)
        
        return cell
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForVisibleCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadImagesForVisibleCells()
        resumeAllOperations()
    }
    
    
    func suspendAllOperations () {
        pendingOperations.downloadQueue.suspended = true
    }
    
    func resumeAllOperations () {
        pendingOperations.downloadQueue.suspended = false
    }
    
    func loadImagesForVisibleCells () {
        if let visiblePaths = tableView.indexPathsForVisibleRows {
            let allPendingOpKeys = Set(pendingOperations.downloadsInProgress.keys)
            
            var toBeCancelledOpKeys = allPendingOpKeys
            let visiblePaths = Set(visiblePaths)
            toBeCancelledOpKeys.subtractInPlace(visiblePaths)
            
            var toBeStartedOpKeys = visiblePaths
            toBeStartedOpKeys.subtractInPlace(allPendingOpKeys)
            
            for opKey in toBeCancelledOpKeys {
                if let pendingDownload = pendingOperations.downloadsInProgress[opKey] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValueForKey(opKey)
            }
            
            for opKey in toBeStartedOpKeys {
                let indexPath = opKey as NSIndexPath
                let photoToProcess = FlickrPhotosAPI.sharedInstance.flickrPhotoAtIndexPath(indexPath)
                if photoToProcess.state != .Downloaded {
                    startDownloadForFlickrPhoto(photoToProcess, indexPath: indexPath)
                }
            }
        }
    }
    
    func startDownloadForFlickrPhoto(flickrPhoto: FlickrPhoto, indexPath: NSIndexPath){
        if pendingOperations.downloadsInProgress[indexPath] != nil {
            return
        }
        
        let downloader = ImageDownloader(flickrPhoto: flickrPhoto, indexPath: indexPath)
        downloader.completionBlock = {
            if downloader.cancelled {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
}
