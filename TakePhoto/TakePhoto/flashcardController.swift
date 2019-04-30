//
//  flashcardController.swift
//  TakePhoto
//
//  Created by GIMM on 4/30/19.
//  Copyright © 2019 Jadryan McLain. All rights reserved.
//

import UIKit
import SQLite

class flashcardController: UIViewController{
    let database = imageDatabaseController.s
    
    @IBAction func nextButton(_ sender: Any) {
        var newImage = database.getRandomImage()
        imageView.image = newImage
    }
    
    @IBOutlet weak var imageView: UIImageView!
}
