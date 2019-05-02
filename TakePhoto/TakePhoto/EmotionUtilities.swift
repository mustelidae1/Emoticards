//
//  EmotionUtilities.swift
//  AzureRequestTest
//
//  Created by Issiac Torrero on 4/29/19.
//  Copyright © 2019 Issiac Torrero. All rights reserved.
//

import Foundation
import UIKit

struct EmotionImagePair{
    let emotion: String
    let imageURL: URL
    let imagePath: String
    var image: UIImage?
    init(emotion: String, url: URL, path: String) {
        self.emotion = emotion
        imageURL = url
        imagePath = path
    }
    
}

class PlaceFaceEmojis {
    
    var angerPair: EmotionImagePair!
    var happyPair: EmotionImagePair!
    var neutralPair: EmotionImagePair!
    var contemptPair: EmotionImagePair!
    var disgustPair: EmotionImagePair!
    var fearPair: EmotionImagePair!
    var sadnessPair: EmotionImagePair!
    var surprisePair: EmotionImagePair!
    
    let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init(){
        
        //*********These are the images that match with each pre determined emotion**********
        angerPair = EmotionImagePair(emotion: "Anger", url: Bundle.main.url(forResource: "anger1", withExtension: "png")!, path: Bundle.main.path(forResource: "anger1", ofType: "png")!)
        
        happyPair = EmotionImagePair(emotion: "Happy", url: Bundle.main.url(forResource: "happiness", withExtension: "png")!, path: Bundle.main.path(forResource: "happiness", ofType: "png")!)
        
        neutralPair = EmotionImagePair(emotion: "Neutral", url: Bundle.main.url(forResource: "neutral", withExtension: "png")!, path: Bundle.main.path(forResource: "neutral", ofType: "png")!)
        
        contemptPair = EmotionImagePair(emotion: "Contempt", url: Bundle.main.url(forResource: "contempt", withExtension: "png")!, path: Bundle.main.path(forResource: "contempt", ofType: "png")!)
        
        disgustPair = EmotionImagePair(emotion: "Disgust", url: Bundle.main.url(forResource: "disgust", withExtension: "png")!, path: Bundle.main.path(forResource: "disgust", ofType: "png")!)
        
        fearPair = EmotionImagePair(emotion: "Fear", url: Bundle.main.url(forResource: "fear", withExtension: "png")!, path: Bundle.main.path(forResource: "fear", ofType: "png")!)
        
        sadnessPair = EmotionImagePair(emotion: "Sadness", url: Bundle.main.url(forResource: "sadness", withExtension: "png")!, path: Bundle.main.path(forResource: "sadness", ofType: "png")!)
        
        surprisePair = EmotionImagePair(emotion: "Surprised", url: Bundle.main.url(forResource: "suprise", withExtension: "png")!, path: Bundle.main.path(forResource: "suprise", ofType: "png")!)
    }
    func drawFaceRect(rects: [[String: Double]], emotionPair: [EmotionImagePair], view: UIImageView) -> EmotionImagePair {
        //grab the width and height of the imageview
        let width: CGFloat = view.frame.size.width
        let height: CGFloat = view.frame.size.height
        //Grab Image frame location in a rect
        let pictureFrameLocation = CGRect(
            origin: CGPoint(x: view.frame.origin.x, y: view.frame.origin.y),
            size: CGSize(width: width, height: height))
        
        
        
        //get all the imageviews for each face
        let images = FindImageRects(faceRects: rects, image: view, pictureFrame: pictureFrameLocation, emotionPairs: emotionPair)
        
        //For each view, add it as a subview
        for views in images {
            view.addSubview(views)
        }
        //Get a snapshot of the imageView and turn it into a UIImage
        let imageWithEmojis = grabSnapshot(imageView: view)
        view.subviews.forEach({$0.removeFromSuperview()})
        
        var first = emotionPair[0]
        first.image = imageWithEmojis
        
        //view.image = imageWithEmojis
        return first
    }
    
    func createView(rect: [String: Double], scaler: [String: CGFloat], pictureFrame: CGRect, EmotionPair: EmotionImagePair) -> UIImageView{
        
        //Pull out each value
        let rectLeft = CGFloat(rect["left"]!)
        let rectTop = CGFloat(rect["top"]!)
        let rectWidth = CGFloat(rect["width"]!)
        let rectHeight = CGFloat(rect["height"]!)
        //Reduce the x and y values to match the scale of the image
        let reducedX = rectLeft * scaler["width"]!
        let reducedY = rectTop * scaler["height"]!
        //combine the frames x and y with the face x and y
        //        let viewLeft = pictureFrame.minX + reducedX
        //        let viewTop = pictureFrame.minY + reducedY
        //create a CGRect using the values from azure
        //Each value is multiplied by the scaling factor to ensure that we get a properly sized rects
        let faceRect = CGRect(x: reducedX, y: reducedY, width: (rectWidth * scaler["width"]!), height: (rectHeight * scaler["height"]!))
        //grab the image, from our emotion pair
        let imageData = GrabImage(path: EmotionPair.imagePath, url: EmotionPair.imageURL)
        //place the image in a variable and assign it to an imageview
        let image = UIImage(data: imageData!)
        let imageView = UIImageView(image: image!)
        //Set the size of the new imageview
        imageView.frame = faceRect
        
        return imageView
    }
    
    func FindImageRects(faceRects: [[String: Double]], image: UIImageView, pictureFrame: CGRect, emotionPairs: [EmotionImagePair]) -> [UIImageView]{
        var emojiImageViews: [UIImageView] = []
        var indexer: Int = 0
        //Get scaling factors for the specified image
        let scalingFactors = calculateImageScalingFactor(image: image)
        //for each face in the image, draw a rectangle around it
        for rect in faceRects{
            //creates a rectangle with the given azure values
            let newEmojiView = self.createView(rect: rect, scaler: scalingFactors, pictureFrame: pictureFrame, EmotionPair: emotionPairs[indexer])
            
            emojiImageViews.append(newEmojiView)
            indexer += 1
        }
        
        return emojiImageViews
    }
    //Function for determing the current scale of the image vs. it's original size
    //This is needed because the values given from azure are based on the original photo
    func calculateImageScalingFactor(image:UIImageView) -> [String: CGFloat]{
        var scalingFactors: [String: CGFloat] = [:]
        //grab actual image dimensions
        let imageHeight = image.image!.size.height
        let imageWidth = image.image!.size.width
        //grab the frame dimensions of the imageview
        let imageContainerHeight = image.frame.size.height
        let imageContainerWidth = image.frame.size.width
        //Calculate the scaling factor and place it in the scalingFactors dictionary
        let scalingFactorHeight = imageContainerHeight / imageHeight
        scalingFactors.updateValue(scalingFactorHeight, forKey: "height")
        let scalingFactorWidth = imageContainerWidth / imageWidth
        scalingFactors.updateValue(scalingFactorWidth, forKey: "width")
        
        return scalingFactors
    }
    
    func determineFaceEmotions(emotions: [[String: Double]]) -> [EmotionImagePair]?{
        var emotionPairArray: [EmotionImagePair] = []
        //Go through each face and grab all emotion values
        for emotion in emotions{
            var emotionArray: [String:Double] = [:]
            let anger = emotion["anger"]!
            emotionArray.updateValue(anger, forKey: "Anger")
            let contempt = emotion["contempt"]!
            emotionArray.updateValue(contempt, forKey: "Contempt")
            let disgust = emotion["disgust"]!
            emotionArray.updateValue(disgust, forKey: "Disgust")
            let fear = emotion["fear"]!
            emotionArray.updateValue(fear, forKey: "Fear")
            let happiness = emotion["happiness"]!
            emotionArray.updateValue(happiness, forKey: "Happiness")
            let neutral = emotion["neutral"]!
            emotionArray.updateValue(neutral, forKey: "Neutral")
            let sadness = emotion["sadness"]!
            emotionArray.updateValue(sadness, forKey: "Sadness")
            let surprise = emotion["surprise"]!
            emotionArray.updateValue(surprise, forKey: "Surprise")
            //Find the largest value in the emotion Array
            let greatestEmotion = emotionArray.max { a, b in a.value < b.value }
            
            //Using the max value, determine which emotion pair we should use for the image.
            switch(greatestEmotion!.key){
            case("Anger"):
                emotionPairArray.append(angerPair)
                break
            case("Contempt"):
                emotionPairArray.append(contemptPair)
                break
            case("Disgust"):
                emotionPairArray.append(disgustPair)
                break
            case("Fear"):
                emotionPairArray.append(fearPair)
                break
            case("Happiness"):
                emotionPairArray.append(happyPair)
                break
            case("Neutral"):
                emotionPairArray.append(neutralPair)
                break
            case("Sadness"):
                emotionPairArray.append(sadnessPair)
                break
            case("Surprise"):
                emotionPairArray.append(surprisePair)
                break
            default:
                emotionPairArray.append(neutralPair)
                break
            }
        }
        return emotionPairArray
        
    }
    
    func grabSnapshot(imageView: UIImageView) -> UIImage{
        let origin = CGPoint(x: 0, y: 0)
        let frameSize = CGSize(width: imageView.frame.width, height: imageView.frame.height)
        
        let imageRect = CGRect(origin: origin, size: frameSize)
        
        // - Where the magic happens
        UIGraphicsBeginImageContextWithOptions(frameSize, true, 0)
        imageView.drawHierarchy(in: imageRect, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let data: Data = image!.jpegData(compressionQuality: 1.0)!
        //let data = UIImageJPEGRepresentation(i, 1.0)
        
        UIGraphicsEndImageContext()
        
        return image!
        //let newImage = UIImage(data: data)
    }
    
    func GrabImage(path: String, url: URL) -> Data?{
        if FileManager.default.fileExists(atPath: path){
            //try and create a data object from the imgURL
            if let imgData = try? Data(contentsOf: url) {
                return imgData
            }else{
                print("ERROR: Cannot convert url to data")
                return nil
            }
        }else{
            print("ERROR: File does not exist at the given path")
            return nil
        }
    }
}
