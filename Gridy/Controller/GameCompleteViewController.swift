//
//  GameCompleteViewController.swift
//  Gridy
////  Created by Luke G on 12/04/2018.
//

import UIKit

class GameCompleteViewController: UIViewController {
    //variables
    @IBOutlet weak var completedImage: UIImageView!
    @IBOutlet weak var finishedInMovesLabel: UILabel!
    var movesCompleted : Int!
    var score : Int!
    var gameImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set finished game label using score and moves
        finishedInMovesLabel.text = "You scored \(score!) in \(movesCompleted!) moves!"
        //set image view as game image
        completedImage.image = gameImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // define content to share
        let note = "I scored \(score!) in \(movesCompleted!) moves!"
        let image = gameImage
        let items = [image as Any, note as Any]
        // create activity view controller
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view // fix for iPad
        // present the view controller
        present(activityViewController, animated: true, completion: nil)
    }

}
