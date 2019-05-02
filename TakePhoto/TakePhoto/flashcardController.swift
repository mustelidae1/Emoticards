//
//  flashcardController.swift
//  TakePhoto
//
//  Created by GIMM on 4/30/19.
//  Copyright © 2019 Jadryan McLain. All rights reserved.
//

import UIKit
import SQLite

class flashcardController: UIViewController {
    let database = imageDatabaseController.s
    var correctEmotion = ""
    var guessedEmotion = ""
    var correctStreak = 0
    var incorrectStreak = 0
    
    @IBOutlet weak var emotionSelect: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        resetView()
        getImage()
    }
    
    @IBAction func submitButton(_ sender: Any) {
        checkGuess()
        resetView()
        //getImage()
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        let segIndex = emotionSelect.selectedSegmentIndex
        var segEmotion = emotionSelect.titleForSegment(at: segIndex)
        segEmotion = segEmotion!.lowercased()
        
        if segIndex == -1 {
            submitButton.isEnabled = false
        } else {
            submitButton.isEnabled = true
        }
        guessedEmotion = segEmotion!
    }
    
    func getImage() {
        let newImageDetails = database.getRandomImage()
        print(newImageDetails)
        imageView.image = newImageDetails.image
        correctEmotion = newImageDetails.emotion!
        correctEmotion = correctEmotion.lowercased()
        
        print("Correct emotion: " + correctEmotion)
    }
    
    func checkGuess() {
        var response = ""
        
        if guessedEmotion == correctEmotion {
            response = "Correct!"
            correctStreak += 1
            incorrectStreak = 0
        } else {
            response = "Incorrect."
            incorrectStreak += 1
            correctStreak = 0
        }
        
        if correctStreak >= 7 {
            print("increase difficulty")
            switch database.difficulty {
            case "easy":
                database.difficulty = "medium"
            case "medium":
                database.difficulty = "hard"
            default:
                database.difficulty = "hard"
            }
        } else if incorrectStreak >= 7 {
            print("decrease difficulty")
            switch database.difficulty {
            case "hard":
                database.difficulty = "medium"
            case "medium":
                database.difficulty = "easy"
            default:
                database.difficulty = "easy"
            }
        }
        
        let dialogMessage = UIAlertController(title: "\(response)", message: "", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            print("Go to next flashcard")
            self.resetView()
            self.getImage()
        })
        let no = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
            print("Abort to main menu")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = storyBoard.instantiateViewController(withIdentifier: "Home")
            self.present(homeViewController, animated: true, completion: nil)
        }
        
        dialogMessage.addAction(yes)
        //dialogMessage.addAction(no)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func resetView() {
        guessedEmotion = ""
        emotionSelect.selectedSegmentIndex = UISegmentedControl.noSegment
        submitButton.isEnabled = false
    }
}
