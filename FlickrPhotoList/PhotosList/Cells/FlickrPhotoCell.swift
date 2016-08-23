//
//  FlickrPhotoCell.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/20/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UITableViewCell {
    private var flickrPhoto:FlickrPhoto?
    
    @IBOutlet weak var roundedView: RoundedViewWithBorder!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        FlickrPhotosAPI.sharedInstance.removeFlickrPhoto(self.flickrPhoto)
        flickrPhoto = nil
        roundedView.image = nil
        titleLabel.text = ""
    }
    
    func updateWithFlickrPhoto (flickrPhoto: FlickrPhoto) {
        self.flickrPhoto = flickrPhoto
        
        if let image = flickrPhoto.image {
            roundedView.image = image
        } else {
            FlickrPhotosAPI.localImageAsyncForFlickrPhoto(flickrPhoto) {[unowned self] (image) in
                if image != nil {
                    flickrPhoto.image = image
                    self.roundedView.image = image
                } else {
                    self.roundedView.image = UIImage(named:"placeholder")
                }
            }
        }
        
        titleLabel.text = flickrPhoto.title
        switch (flickrPhoto.state){
        case .Downloaded:
            activityIndicator.stopAnimating()
        case .Failed:
            activityIndicator.stopAnimating()
        case .New:
            activityIndicator.startAnimating()
        }
    }
}