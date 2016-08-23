//
//  TemporaryFileManager.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/22/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

public class TemporaryFileManager  {
    
    static let sharedInstance = TemporaryFileManager()
    let temporaryDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("TempImageFolder")
    
    public typealias TempFileWriteCompletionHandler = (result:() throws -> NSURL) -> Void
    public typealias TempFileWipeCompletionHandler = (result:() throws -> Void) -> Void
    
    init() {
        var isDir : ObjCBool = false
        guard NSFileManager.defaultManager().fileExistsAtPath(temporaryDirectoryURL.path!,isDirectory:&isDir ) else {
            if !isDir{
                do {
                    try NSFileManager.defaultManager().createDirectoryAtURL(temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    print("Error creating temporary directory \(error.localizedDescription)")
                }
            }
            
            return
        }
    }
    
    public func fileExistWithID (title:String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        if let path = URLBuilder.localFlickrURL(withId: title).path {
            return fileManager.fileExistsAtPath(path)
        } else {
            return false
        }
    }
    
    public func writeTemporaryFile(data:NSData, title:String, fn:TempFileWriteCompletionHandler?) {
        dispatch_user_initiated {
            do {
                let fileURL = URLBuilder.localFlickrURL(withId: title)
                try data.writeToURL(fileURL, options: NSDataWritingOptions.DataWritingAtomic)
                print ("WRITE PATH: \(fileURL)")
                dispatch_main { fn?(result:{return fileURL}) }
            } catch let error as NSError {
                print("Error writing data to url \(error.localizedFailureReason)")
                dispatch_main { fn?(result:{throw error}) }
            }
        }
    }
    
    public func writeSynchronousTemporaryFile(data:NSData, title:String) throws -> NSURL {
        do {
            let fileURL = URLBuilder.localFlickrURL(withId: title)
            
            try data.writeToURL(fileURL, options: NSDataWritingOptions.DataWritingWithoutOverwriting)
            print ("WRITE PATH: \(fileURL)")
            return fileURL
        } catch let error as NSError {
            print("Error writing data to url \(error.localizedFailureReason)")
            throw error
        }
    }
    
    public func imageByURL(url:NSURL?) -> UIImage?{
        if let url = url, let data = NSData(contentsOfURL : url) {
            let image = UIImage(data : data)
            return image
        } else {
            return nil
        }
    }
    
    public func deleteTemporaryFile(url:NSURL, fn:TempFileWipeCompletionHandler?) {
        dispatch_user_initiated {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
                print("Successfully deleted file at url \(url) temporary files")
                dispatch_main { fn?(result: {}) }
            } catch let error as NSError {
                print(error.localizedDescription)
                dispatch_main { fn?(result:{throw error}) }
            }
        }
    }
    public func deleteTemporaryFiles(fn:TempFileWipeCompletionHandler?) {
        dispatch_user_initiated {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self.temporaryDirectoryURL)
                do {
                    try NSFileManager.defaultManager().createDirectoryAtURL(self.temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    print("Error creating temporary directory \(error.localizedDescription)")
                }
                print("Successfully deleted all temporary files")
                dispatch_main { fn?(result: {}) }
            } catch let error as NSError {
                print(error.localizedDescription)
                dispatch_main { fn?(result:{throw error}) }
            }
        }
    }
}

/*
 GCD Helper Functions
 */

func dispatch_main(fn:dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), fn);
}

func dispatch_user_initiated(fn:dispatch_block_t) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), fn)
}

func dispatch_once(fn:dispatch_block_t) {
    var obj : dispatch_once_t = 0
    dispatch_once(&obj, fn)
}