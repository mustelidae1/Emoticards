//
//  ViewController.swift
//  TakePhoto
//
//  Created by Jadryan McLain on 4/16/19.
//  Copyright © 2019 Jadryan McLain. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController{
    let database = imageDatabaseController.s
    @IBAction func clearDatabase(_ sender: Any) {
        database.clearDatabase() 
    }
}

