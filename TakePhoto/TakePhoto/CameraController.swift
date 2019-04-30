//
//  CameraController.swift
//  TakePhoto
//
//  Created by GIMM on 4/25/19.
//  Copyright © 2019 Jadryan McLain. All rights reserved.
//

import Foundation
import UIKit

class CameraController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    let database = imageDatabaseController.s

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        imageView.image = image
        
        // TODO: Might need to put some of Issiac's code here if it needs access to an ImageView 
        
        database.savePhotoController(image: image!)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
}
