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
import CoreImage


struct ImageDetail {
    var image: UIImage?
    var emotion: String?
}

extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImage.Orientation.up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if ( self.imageOrientation == UIImage.Orientation.down || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.left || self.imageOrientation == UIImage.Orientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.right || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2.0));
        }
        
        if ( self.imageOrientation == UIImage.Orientation.upMirrored || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if ( self.imageOrientation == UIImage.Orientation.leftMirrored || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;
        
        ctx.concatenate(transform)
        
        if ( self.imageOrientation == UIImage.Orientation.left ||
            self.imageOrientation == UIImage.Orientation.leftMirrored ||
            self.imageOrientation == UIImage.Orientation.right ||
            self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
}

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
    
    // The names here are the names of the image files in Assets.xcassets
    var collectionImages: [UIImage] = [
        UIImage(named: "image1")!,
    ]
    
    var collectionImagesEmojis: [UIImage] = [
        UIImage(named: "image1")!,
    ]
    
    var collectionImagesShader: [UIImage] = [
        UIImage(named: "image1")!,
    ]
    
    var collectionImageEmotions: [String] = [
        "Happiness",
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
                let imageDataEmoji = try Data(contentsOf: URL(fileURLWithPath: image[filePathEasy]))
                let canvasImageEmoji = UIImage(data: imageDataEmoji)
                let imageDataShader = try Data(contentsOf: URL(fileURLWithPath: image[filePathMedium]))
                let canvasImageShader = UIImage(data: imageDataShader)
                collectionImages.append(canvasImage!)
                imageLabels.append(image[date])
                collectionImagesEmojis.append(canvasImageEmoji!)
                collectionImagesShader.append(canvasImageShader!) 
            }
        } catch {
            print(error)
        }
    }
    
    
    public func getRandomImage() -> ImageDetail {
        print("Getting random image")
        let randomIndex = Int.random(in: 0 ..< collectionImages.count);
        var imageDetails = ImageDetail()
        
        //do {
            //let randomImage = images.filter(date == imageLabels[randomIndex])
            //var imageData = Data()
            
            //for image in try db!.prepare(randomImage){
                //imageDetails.emotion = image[emotion]
            var canvasImage:UIImage = UIImage()
                if (difficulty == "easy") {
                    //imageData = try Data(contentsOf: URL(fileURLWithPath: collectionImagesEmojis[randomIndex])
                    print("Getting easy difficulty image")
                    canvasImage = collectionImagesEmojis[randomIndex]
                } else if (difficulty == "medium") {
                    //imageData = try Data(contentsOf: URL(fileURLWithPath: collectionImagesShader[randomIndex]))
                    print("Getting medium difficulty image")
                    canvasImage = collectionImagesShader[randomIndex]
                } else if (difficulty == "hard") {
                    //imageData = try Data(contentsOf: URL(fileURLWithPath: image[filePathHard]))
                    print("Getting hard difficulty image")
                    canvasImage = collectionImages[randomIndex]
                }
                
               // let canvasImage = UIImage(data: imageData)
                imageDetails.image = canvasImage
                imageDetails.emotion = collectionImageEmotions[randomIndex]
                
                return imageDetails
            //}
        //} catch {
         //   print(error)
        //}
        
        //return ImageDetail(image: collectionImages[randomIndex], emotion: "happiness")
    }
    
    
    
    
  /*  public func getRandomImage() -> UIImage {
        let randomIndex = Int.random(in: 0 ..< collectionImages.count);
        var imageDetails = Dictionary<String, Any>()

        if (difficulty == "hard") {
            return collectionImages[randomIndex]
        } else {
            do {
                let randomImage = images.filter(date == imageLabels[randomIndex])
                var imageData = Data()

                for image in try db!.prepare(randomImage){
                    imageDetails["emotion"] = image[emotion]

                    if (difficulty == "easy") {
                        imageData = try Data(contentsOf: URL(fileURLWithPath: image[filePathEasy]))
                    } else if (difficulty == "medium") {
                        imageData = try Data(contentsOf: URL(fileURLWithPath: image[filePathMedium]))
                    } else {
                        imageDetails["image"] = UIImage()
                        return imageDetails
                    }

                    let canvasImage = UIImage(data: imageData)
                    imageDetails["image"] = UIImage()

                    return imageDetails
                }
            } catch {
                print(error)
            }
        }
        return UIImage()
    }*/
    
    public func clearDatabase() {
        do {
            try db!.run(images.delete())
            collectionImages = [UIImage]()
            collectionImagesEmojis = [UIImage]()
            collectionImagesShader = [UIImage]()
            collectionImageEmotions = [String]() 
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
    

    
    func savePhotoController(image: UIImage, emojiImage: UIImage, imageEmotion: String) {
        //imagePicker.dismiss(animated: true, completion: nil)
        //imageView.image = image
        
        
        // do azure stuff
        let pictureEmotion = imageEmotion
        
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
            
            //print(newFileUrlEasy)
            
            do {
                // TODO
                // add emoji here
                // Call Issiac's code here
                // Use the UIImage returned from Issiac's code instead of "image" below
                if let jpgImageDataEasy = emojiImage.jpegData(compressionQuality: 0.5){
                    try jpgImageDataEasy.write(to: URLStringEasy)
                }
                

                //Sets the imgview to the filter and calls the apply filter function
                var correctlyOrientedImage = image.fixOrientation()
                let comicImage = applyFilterTo(image: correctlyOrientedImage, filterEffect: Filter(filterName: "CIComicEffect", filterEffectValue: nil, filterEffectValueName: nil))
                if let jpgImageDataMedium = comicImage!.jpegData(compressionQuality: 0.5){
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
            for image in try db!.prepare(insertedPhoto){
                
                print("filePathHard: \(image[filePathHard])")
                let imageData = try Data(contentsOf: URL(fileURLWithPath: image[filePathHard]))
                let canvasImage = UIImage(data: imageData)
                
                let imageDataEmoji = try Data(contentsOf: URL(fileURLWithPath: image[filePathEasy]))
                let canvasImageEmoji = UIImage(data: imageDataEmoji)
                
                let imageDataShader = try Data(contentsOf: URL(fileURLWithPath: image[filePathMedium]))
                let canvasImageShader = UIImage(data: imageDataShader)
                //self.imageView.image = canvasImage
                //try db!.run(angry.delete())
                
                collectionImages.append(canvasImage!)
                collectionImagesEmojis.append(canvasImageEmoji!)
                collectionImagesShader.append(canvasImageShader!)
                collectionImageEmotions.append(image[emotion])
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
}


