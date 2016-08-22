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
        
        switch (flickrPhoto.state){
        case .Downloaded:
            cell.activityIndicator.stopAnimating()
        case .Failed:
            cell.activityIndicator.stopAnimating()
        case .New:
            cell.activityIndicator.startAnimating()
            if (!tableView.dragging && !tableView.decelerating) {
                startDownloadForFlickrPhoto(flickrPhoto, indexPath: indexPath)
            }
        }
        
        return cell
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    
    func suspendAllOperations () {
        pendingOperations.downloadQueue.suspended = true
    }
    
    func resumeAllOperations () {
        pendingOperations.downloadQueue.suspended = false
    }
    
    func loadImagesForOnscreenCells () {
        if let pathsArray = tableView.indexPathsForVisibleRows {
            let allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtractInPlace(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtractInPlace(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
            }
            
            for indexPath in toBeStarted {
                let indexPath = indexPath as NSIndexPath
                let photoToProcess = FlickrPhotosAPI.sharedInstance.flickrPhotoAtIndexPath(indexPath)
                if photoToProcess.state != .Downloaded {
                    startDownloadForFlickrPhoto(photoToProcess, indexPath: indexPath)
                }
            }
        }
    }
}
