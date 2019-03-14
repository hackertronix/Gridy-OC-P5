//
//  ImageEditorViewController.swift
//  Gridy
//
//

import UIKit
import Photos
import AVFoundation

class ImageEditorViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //variable for the image view the user is editing
    @IBOutlet weak var loadedImage: UIImageView!
    //variable for the editor box which will be the game image
    @IBOutlet weak var cropImageBoxView: UIView!
    //variable to hold the user chosen image that is passed by the main screen
    var imageToEdit: UIImage!
    //holds position of view
    var initialImageViewOffset = CGPoint()
    //Int to hold the size of the grid
    var gridSize: Int!

    
    override func viewDidLoad() {
        //set the image view image as the image chosen by the user
        loadedImage.image = imageToEdit
        configure()
    }

    func configure() {
        //set up the gesture recognizers
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImage(_:)))
        loadedImage.addGestureRecognizer(panGestureRecognizer)
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage(_:)))
        loadedImage.addGestureRecognizer(rotationGestureRecognizer)
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomImage(_:)))
        loadedImage.addGestureRecognizer(pinchGestureRecognizer)
        //set gesture recognizer delegates
        panGestureRecognizer.delegate = self
        rotationGestureRecognizer.delegate = self
        pinchGestureRecognizer.delegate = self
        //set the crop image box view dimensions to 80% of the shortest screen size
        if view.frame.height > view.frame.width {
            let boxdimensions = view.frame.width * 0.8
            cropImageBoxView.frame = CGRect(x: 0.0, y: 0.0, width: boxdimensions, height: boxdimensions)
        } else {
            let boxdimensions = view.frame.height * 0.8
            cropImageBoxView.frame = CGRect(x: 0.0, y: 0.0, width: boxdimensions, height: boxdimensions)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //send the image to the game view controller
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "FinishedEditingSegue" {
             let vc = segue.destination as! GameViewController
             vc.gameImage = composeCreationImage()
             vc.gridSize = self.gridSize
         }
     }

//MARK: Gesture recognisers
    
    //move the image when the pan gesture is used
    @objc func moveImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: loadedImage.superview)
        if sender.state == .began {
            //store starting position
            initialImageViewOffset = loadedImage.frame.origin
        }
        //find position based on movement and starting position
        let position = CGPoint(x: translation.x + initialImageViewOffset.x - loadedImage.frame.origin.x, y: translation.y + initialImageViewOffset.y - loadedImage.frame.origin.y)
        //transform to new position
        loadedImage.transform = loadedImage.transform.translatedBy(x: position.x, y: position.y)
    }
    
    //rotate the image when the rotate gesture is used
    @objc func rotateImage(_ sender: UIRotationGestureRecognizer) {
        loadedImage.transform = loadedImage.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    //zoom the image when the zoom gesture is used
    @objc func zoomImage(_ sender: UIPinchGestureRecognizer) {
        loadedImage.transform = loadedImage.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    //enables multiple touch gestures to be recognised
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            //only allow multiple gestures on the image view
            if gestureRecognizer.view != loadedImage {
                return false
            }
            //the multiple gestures should not be tap gesture so that the user can't click a button whilst resizing, rotating, etc
            if gestureRecognizer is UITapGestureRecognizer
                || otherGestureRecognizer is UITapGestureRecognizer {
                return false
            }
            return true
    }
    
//MARK: Image Cropping
    //crops the image to the contents of the editor box
    func composeCreationImage() -> UIImage{
        //initialize the image creation the size of the editor box
        UIGraphicsBeginImageContextWithOptions(cropImageBoxView.bounds.size, false, 0)
        //ensure views and sub-views are up to date
        cropImageBoxView.drawHierarchy(in: cropImageBoxView.bounds, afterScreenUpdates: true)
        //screenshot the image
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        //end iage manipulation
        UIGraphicsEndImageContext()
        //return the cropped image
        return screenshot
    }
}
