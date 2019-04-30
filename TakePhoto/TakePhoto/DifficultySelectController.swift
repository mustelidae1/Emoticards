//
//  DifficultySelectController.swift
//  TakePhoto
//
//  Created by GIMM on 4/30/19.
//  Copyright © 2019 Jadryan McLain. All rights reserved.
//

import UIKit
import SQLite

class DifficultySelectController: UIViewController{
    let database = imageDatabaseController.s
    
    
    @IBAction func easyButton(_ sender: Any) {
        database.setDifficulty(newDifficulty: "easy")
    }
    
    @IBAction func mediumButton(_ sender: Any) {
        database.setDifficulty(newDifficulty: "medium")
    }
    
    @IBAction func hardButton(_ sender: Any) {
        database.setDifficulty(newDifficulty: "hard")
    }
}
