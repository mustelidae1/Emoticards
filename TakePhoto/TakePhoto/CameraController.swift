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
    
    let azure = AzureUtils()
    let emoji = PlaceFaceEmojis()
    var currFaceRects: [[String: Double]] = []
    
    let APIKey = "d480c3c6bd11476380f869cb9ec709b3"
    
    //Region used for api
    let region = "westus"
    
    //Preformatted URL for API request
    //You can put additional parameteres here so the api returns different things in the json object
    let azureURL = URL(string: "https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceAttributes=emotion")
    
    var backgroundQueue: DispatchQueue!
    
    
    var imagePicker: UIImagePickerController!
    let database = imageDatabaseController.s
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundQueue = DispatchQueue(label: "background", qos: .background)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        imageView.image = image
        
        if let jpegImageData = image?.jpegData(compressionQuality: 0.5) {
            makeRequest(imageData: jpegImageData)
        }
        
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Function for handling the request to the azure API
    func makeRequest(imageData: Data) {
        //Specifying the headers for the request
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/octet-stream" //This can be application/octet-stream or application/json
        headers["Ocp-Apim-Subscription-Key"] = APIKey
        //let data = try! JSONSerialization.data(withJSONObject: params)
        
        //Make API call on the second thread, that way the UI doesn't get effected
        backgroundQueue.async {
            //Store whatever we get from the API in a variable
            let response = self.azure.makeAzurePostRequest(apiURL: self.azureURL!, imageData: imageData, headers: headers)
            
            print("***************Got Request from API*****************")
            //Print out what we got back
            print(response)
            //parse all the emotions in the response
            let emotions = self.azure.ParseEmotions(json: response)
            //grab face rectangles from response
            self.currFaceRects = self.azure.GrabFaceRects(json: response)
            
            
            //print out individual emotions, this will be used for determing overall emotion
            let emotionImagePairArray = self.emoji.determineFaceEmotions(emotions: emotions)
            //Switch back to main thread to draw rectangle and update the view
            DispatchQueue.main.async{
                var emotionImagePair = self.emoji.drawFaceRect(rects: self.currFaceRects, emotionPair: emotionImagePairArray!, view: self.imageView)
                
                self.database.savePhotoController(image: self.imageView.image!, emojiImage: emotionImagePair.image!, imageEmotion: emotionImagePair.emotion)
            }
        }
        
    }
    
}
