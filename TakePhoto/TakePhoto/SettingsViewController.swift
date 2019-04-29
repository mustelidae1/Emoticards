//
//  SettingsViewController.swift
//  TakePhoto
//
//  Created by GIMM on 4/25/19.
//  Copyright © 2019 Jadryan McLain. All rights reserved.
//

import UIKit
import SQLite

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var imagePicker: UIImagePickerController!

    let database = imageDatabaseController.s
    
    let images = Table("images")
    var imageLabels: [String] = [String]()
    
    // The names here are the names of the image files in Assets.xcassets
    var collectionImages: [UIImage] = [UIImage]()
    

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    func openGrid(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(promptDeletePhotos))
        if (collectionView == nil){
            print("self is nil")
        } else{
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.allowsMultipleSelection = true
            
            // Set padding around each cell
            let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            layout.minimumInteritemSpacing = 3
            layout.itemSize = CGSize(width: (self.collectionView.frame.size.width - 20)/6, height: self.collectionView.frame.size.height/3)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Settings Page Loaded")
        openGrid()
        collectionImages = database.getCollectionImages()
        imageLabels = database.getImageLabels()
    }
    
    
    
    @objc func promptDeletePhotos(sender: AnyObject) {
        print("delete this now")
        let itemsToDelete = collectionView.indexPathsForSelectedItems!
        let numToDelete = itemsToDelete.count
        
        let dialogMessage = UIAlertController(title: "Delete Photos", message: "Are you sure you want to delete \(numToDelete) photos?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            print("Delete confirmed")
            self.deletePhotos()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        
        dialogMessage.addAction(yes)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    func deletePhotos() {
        // TO-DO: actually delete photos here
        print("delete function called")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.cellLabel.text = imageLabels[indexPath.item]
        cell.cellImageView.image = collectionImages[indexPath.item]
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        
        return cell
    }
    
    // Change cell visually on selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 2
    }
    
    // Return cell to normal on deselection
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = 0.5
    }
    
    
}

