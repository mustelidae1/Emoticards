//
//  imageDatabaseController.swift
//  TakePhoto
//
//  Created by GIMM on 4/25/19.
//  Copyright © 2019 Jadryan McLain. All rights reserved.
//

import Foundation
import UIKit
import SQLite

class imageDatabaseController{
    static let s = imageDatabaseController()
    var imagePicker: UIImagePickerController!
    let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fm = FileManager.default
    var db: Connection?
    
    let id = Expression<Int64>("id")
    let date = Expression<String>("date")
    let filePathEasy = Expression<String>("filePathEasy")
    let filePathMedium = Expression<String>("filePathMedium")
    let filePathHard = Expression<String>("filePathHard")
    let emotion = Expression<String>("emotion")
    
    let images = Table("images")
    var imageLabels = ["image1"]
    
    var difficulty = "easy"
    
    // The names here are the names of the image files in Assets.xcassets
    var collectionImages: [UIImage] = [
        UIImage(named: "image1")!,
        /*UIImage(named: "image2")!,
         UIImage(named: "image3")!,
         UIImage(named: "image4")!,
         UIImage(named: "image5")!,
         UIImage(named: "image6")!,
         UIImage(named: "image7")!,
         UIImage(named: "image8")!,
         UIImage(named: "image9")!,*/
    ]
    
    var selectedImages = [Number]()
    
    private init(){
        print("take photo")
        openDB()
        do {
            
            
            do{
                try db!.scalar(images.exists)
            } catch {
                
                try db!.run(images.create { t in
                    t.column(id, primaryKey: true)
                    t.column(date)
                    t.column(filePathEasy, unique: true)
                    t.column(filePathMedium, unique: true)
                    t.column(filePathHard, unique: true)
                    t.column(emotion)
                })
                
            }
            
            getAllImages()
          
            
        } catch {
            print(error)
        }
    }
    
    public func setDifficulty(newDifficulty: String) {
        difficulty = newDifficulty 
    }
    
    public func getAllImages() {
        do {
            for image in try db!.prepare(images) {
                print("id: \(image[id]), date: \(image[date]), filePathEasy: \(image[filePathEasy]), filePathMedium: \(image[filePathMedium]), filePathHard: \(image[filePathHard]), emotion: \(image[emotion])")
                
                let imageData = try Data(contentsOf: URL(fileURLWithPath: image[filePathHard]))
                let canvasImage = UIImage(data: imageData)
                collectionImages.append(canvasImage!)
                imageLabels.append(image[date])
            }
        } catch {
            print(error)
        }
    }
    
    public func getRandomImage() -> UIImage {
        let randomIndex = Int.random(in: 0 ..< collectionImages.count);
        
        if (difficulty == "hard") {
            return collectionImages[randomIndex]
        } else {
            do {
                let randomImage = images.filter(date == imageLabels[randomIndex])
                var imageData = Data()
                
                for image in try db!.prepare(randomImage){
                    if (difficulty == "easy") {
                        imageData = try Data(contentsOf: URL(fileURLWithPath: image[filePathEasy]))
                    } else if (difficulty == "medium") {
                        imageData = try Data(contentsOf: URL(fileURLWithPath: image[filePathMedium]))
                    } else {
                        return UIImage()
                    }
                    
                    let canvasImage = UIImage(data: imageData)
                    return canvasImage!
                }
            } catch {
                print(error)
            }
        }
         return UIImage()
    }
    
    public func clearDatabase() {
        do {
            try db!.run(images.delete())
            collectionImages = [UIImage]()
            imageLabels = [String]() 
        } catch {
           print(error)
        }
    }
    
    public func getCollectionImages() -> [UIImage] {
        return collectionImages
    }
    
    public func getImageLabels() -> [String] {
        return imageLabels 
    }
    
    func openDB() -> Connection {
        if db == nil {
            do {
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileUrl =
                    documentDirectory.appendingPathComponent("images").appendingPathExtension("sqlite3")
                db = try Connection(fileUrl.path)
            } catch {
                print(error)
            }
        }
        return db!
    }
    

    
    func savePhotoController(image: UIImage) {
        //imagePicker.dismiss(animated: true, completion: nil)
        //imageView.image = image
        
        
        // do azure stuff
        let pictureEmotion = "angry"
        
        do {
            
            let curdate = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: curdate)
            let year = calendar.component(.year, from: curdate)
            let hour = calendar.component(.hour, from: curdate)
            let minute = calendar.component(.minute, from: curdate)
            let second = calendar.component(.second, from: curdate)
            let fullDate = String(year) + "-" + String(day) + "-" + String(hour) + "-" + String(minute) + "-" + String(second) + "-"
            
            
            //let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            //let pathURL = fileURLWithPath
            //let destPath = documentsURL.appendingPathComponent(pathURL.path, isDirectory: true)
            //let destString = destPath.relativePath
            let newFileUrlEasy = pathURL.appendingPathComponent(fullDate + "easy" + ".jpg").relativePath
            let newFileUrlMedium = pathURL.appendingPathComponent(fullDate + "medium" + ".jpg").relativePath
            let newFileUrlHard = pathURL.appendingPathComponent(fullDate + "hard" + ".jpg").relativePath
            
            let URLStringEasy = URL(fileURLWithPath: newFileUrlEasy)
            let URLStringMedium = URL(fileURLWithPath: newFileUrlMedium)
            let URLStringHard = URL(fileURLWithPath: newFileUrlHard)
            
            //try FileManager.default.createDirectory(at: newFileUrlEasy, withIntermediateDirectories: true, attributes: nil)
            
            print(newFileUrlEasy)
            
            do {
                // TODO
                // add emoji here
                // Call Issiac's code here
                // Use the UIImage returned from Issiac's code instead of "image" below
                if let jpgImageDataEasy = image.jpegData(compressionQuality: 0.5){
                    try jpgImageDataEasy.write(to: URLStringEasy)
                }
                
                // TODO
                // add shader here
                // Call Brendan's code here
                //Setup a simple way to choose effect values
                struct Filter {
                    let filterName:String
                    var filterEffectValue:Any?
                    var filterEffectValueName:String?
                    
                    init(filterName: String, filterEffectValue: Any?, filterEffectValueName:String?) {
                        self.filterName = filterName
                        self.filterEffectValue = filterEffectValue
                        self.filterEffectValueName = filterEffectValueName
                    }
                }
                
                //Reference the image View probably done already so i commented it out
                    //@IBOutlet weak var imgView: UIImageView!
                
                //Function that atually applies the filters. should be called when we want ta filter applied
                func applyFilterTo(image: UIImage, filterEffect: Filter)-> UIImage?{
                    
                    guard let cgImage = image.cgImage,
                        let openGLContext = EAGLContext(api: .openGLES3) else{
                            return nil
                    }
                    
                    let context = CIContext(eaglContext:openGLContext)
                    
                    let ciImage = CIImage(cgImage: cgImage)
                    let filter = CIFilter(name: filterEffect.filterName)
                    
                    filter?.setValue(ciImage, forKey: kCIInputImageKey)
                    
                    if let filterEffectValue = filterEffect.filterEffectValue,
                        let filterEffectValueName = filterEffect.filterEffectValueName{
                        filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
                    }
                    
                    var filteredImage:UIImage?
                    
                    if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
                        let cgiImageResult = context.createCGImage(output, from: output.extent){
                        filteredImage = UIImage(cgImage: cgiImageResult)
                    }
                    
                    return filteredImage
                }
                
//                //how the function above is called was originally called through a button so needs to be adjusted to just be called if the difficulty is correct
//                @IBAction func comicEffect(_ sender: Any) {
//                //image should = the reference to the image we are filtering
//                    guard let image = imgView.image else{
//                        return
//                    }
//               //Sets the imgview to the filter and calls the apply filter function
//                    imgView.image = applyFilterTo(image: image, filterEffect: Filter(filterName: "CIComicEffect", filterEffectValue: nil, filterEffectValueName: nil))
//
//                }

                //End Brendan's Code
               
                // Use the UIImage returned from Brendan's code instead of "image" blow
                if let jpgImageDataMedium = image.jpegData(compressionQuality: 0.5){
                    try jpgImageDataMedium.write(to: URLStringMedium)
                }
                
                // this one is fine - just the plain image
                if let jpgImageDataHard = image.jpegData(compressionQuality: 0.5){
                    try jpgImageDataHard.write(to: URLStringHard)
                }
                
            }
            
            let insert = images.insert(date <- fullDate, filePathEasy <- newFileUrlEasy, filePathMedium <- newFileUrlMedium, filePathHard <- newFileUrlHard, emotion <- pictureEmotion)
            let rowid = try db!.run(insert)
            
            
            for image in try db!.prepare(images) {
                print("id: \(image[id]), date: \(image[date]), filePathEasy: \(image[filePathEasy]), filePathMedium: \(image[filePathMedium]), filePathHard: \(image[filePathHard]), emotion: \(image[emotion])")
            }
            // SELECT * FROM "users"
            
            let insertedPhoto = images.filter(filePathEasy == newFileUrlEasy)
            for emotion in try db!.prepare(insertedPhoto){
                
                print("filePathHard: \(emotion[filePathHard])")
                let imageData = try Data(contentsOf: URL(fileURLWithPath: emotion[filePathHard]))
                let canvasImage = UIImage(data: imageData)
                //self.imageView.image = canvasImage
                //try db!.run(angry.delete())
                
                collectionImages.append(canvasImage!)
                imageLabels.append(fullDate)
                
            }
            
            
            
            
            //try db.run(angry.update(email <- email.replace("mac.com", with: "me.com")))
            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
            // WHERE ("id" = 1)
            
            //try db!.run(images.delete())
            // DELETE FROM "users" WHERE ("id" = 1)
            
            //try db.scalar(images.count) // 0
            // SELECT count(*) FROM "users"
        } catch {
            print(error)
        }
    }
}


