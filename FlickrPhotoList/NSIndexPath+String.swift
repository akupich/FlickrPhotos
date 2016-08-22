//
//  NSIndexPath+String.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/22/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import Foundation

public extension NSIndexPath {
    
    func toString () -> String {
        return "\(self.section)_\(self.row)"
    }
}

public extension String {
    
    func toIndexPath () -> NSIndexPath? {
        
        let components = self.componentsSeparatedByString("_")
        if let row = Int(components[1]), let section = Int(components[0]) where components.count == 2{
            return NSIndexPath(forRow: row, inSection: section)
        } else {
            return nil
        }
    }
}