//
//  ViewController.swift
//  FlickrPhotoList
//
//  Created by Andriy Kupich on 8/20/16.
//  Copyright © 2016 Remit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource:PhotosDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Flicker Photos"
        
        dataSource = PhotosDataSource(tableView: tableView)
    }
}