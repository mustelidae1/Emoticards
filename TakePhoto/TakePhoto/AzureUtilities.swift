//
//  AzureEmotionParser.swift
//  AzureRequestTest
//
//  Created by Issiac Torrero on 4/14/19.
//  Copyright © 2019 Issiac Torrero. All rights reserved.
//

import Foundation
import UIKit


class AzureUtils{
    
    func ParseEmotions(json: [AnyObject]) -> [[String: Double]] {
        //Create an array to hold the objects for facial emotion
        var facesArray: [[String:Double]] = []
        //Loop through all the faces in the json object
        for face in json{
            //Grab the face attributes specifically and cast it to a NSDictionary
            let faceAttributes = face["faceAttributes"] as? NSDictionary
            //Grab the emotions from the faceAttributes casting it to an object
            let emotions = faceAttributes?["emotion"] as? [String: Double]
            //append it to the existing array
            facesArray.append(emotions!)
        }
        //return our array of emotions
        return facesArray
    }
    
    func GrabFaceRects(json: [AnyObject]) -> [[String: Double]]{
        var faceRectanglesArray: [[String: Double]] = []
        
        //Loop through all the faces in the json object
        for face in json{
            //Grab the face attributes specifically and cast it to a NSDictionary
            let faceRectangle = face["faceRectangle"] as? [String: Double]
            //append it to the existing array
            faceRectanglesArray.append(faceRectangle!)
        }
        return faceRectanglesArray
    }

    
    //Function for making the post request to the API
    func makeAzurePostRequest(apiURL: URL, imageData: Data, headers: [String: String] = [:]) -> [AnyObject]{
        //Create a holder that we can fill with whatever we get from the API
        var object: [AnyObject] = []
        //Create the params for the API call, only needed if passing in a json object
        let params: [String: Any] = [
            
            "url": "Some image url"
            
        ]
        //Searialize the params object
        //let data = try! JSONSerialization.data(withJSONObject: params)
        
        //Create the request variable and set the method and body
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.httpBody = imageData
        //Grab each value in the headers array and add it to the request variable
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        //Set up a semaphore to ensure we aren't trying to use a thread that is already in use
        let semaphore = DispatchSemaphore(value: 0)
        //Create the request
        let task = URLSession.shared.dataTask(with:request){ data, response, error in
            //Print out the response no matter what ****for debugging****
            //print(response ?? URLResponse())
            //If we can serialize the data that we get back from the request assign it to the object variable
            if let data = data, let json = try? JSONSerialization.jsonObject(with:data, options: []) as? [AnyObject], json != nil {
                object = json
            }
            else {
                print("ERROR response: \(String(data: data!, encoding: .utf8) ?? "")")
                
            }
            //Increments the semaphore
            //Signalling that it is in use
            semaphore.signal()
            
        }
        //resume the task, this is required to start the request
        task.resume()
        //Decrements the semaphore after a certain amount of time
        //DispatchTime.distantFuture will wait indefinetly until either the task is completed or it times out
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        //Give the json object back to the calling function
        return object
        
    }
}

