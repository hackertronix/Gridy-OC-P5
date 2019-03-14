//
//  ViewController.swift
//  Gridy
//
//

import UIKit
import Photos
import AVFoundation

//delegates for gesture recognizer, camera and photo library access
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate  {
    //array to store default images
    var localImages = [UIImage].init()
    //holds the image the user has chosen
    var userChosenImage: UIImage?
    //a variable for the grid size allows future functionality to have difficulty levels with different grid sizes, for now always 4 to signify a 4x4 grid
    var gridSize: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //populates the set of default images
        populateImageSet()
        //signifies the grid size i.e. a 4x4 square, in future can add a difficulty setting to increase grid size
        gridSize = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //passess all the required information to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        //if editor segue then pass user selected image to editor vc
        case "EditorSegue":
            let vc = segue.destination as! ImageEditorViewController
            vc.imageToEdit = userChosenImage
            vc.gridSize = self.gridSize
        //if game segue then pass the app chosen random image to the game vc
        case "GameSegue":
            let vc = segue.destination as! GameViewController
            vc.gameImage = getRandomImage()
            vc.gridSize = self.gridSize
        default:
            print("Nothing to do")
        }
    }
    
    //handle the photo library button being pressed
    @IBAction func photoLibraryButtonPressed(_ sender: Any) {
        self.photoLibraryImage()
    }
    
    //handle the camera button being pressed
    @IBAction func cameraButtonPressed(_ sender: Any) {
        self.cameraImageChosen()
    }
    
//MARK: Random image set up and functions
    
    //return a random image from the image set
    func getRandomImage() -> UIImage? {
        if localImages.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(localImages.count)))
            let randomImage = localImages[randomIndex]
            return randomImage
        }
        return nil
    }
    
    //populate the image set with default images
    func populateImageSet() {
        //put all the Gridy standard images into an image set
        localImages.removeAll()
        let imageNames = ["1@2", "2@2", "3@2", "4@2", "5@2"]
        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImages.append(image)
            }
        }
    }
    
//MARK: Image Picker (camera and photo library) functions
    
    //check the status and access to the camera before loading the view
    func cameraImageChosen() {
        let sourceType = UIImagePickerControllerSourceType.camera
        //get current status of camera access
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        //check if camera available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            //message if no access
            let noAccessMessage = "Gridy needs access to your camera to take an image"
            //handle status appropriately
            switch status {
            //if there is no permission set, request permission
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    //if permission is granted call function that presents camera view
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        //if permission denied call function that presents alert message to user
                        self.problemAlertMessage(message: noAccessMessage)
                    }
                })
            //if permission already held call function that presents camera view
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            //if permission restricted or denied call function to present alert message to user
            case .restricted, .denied:
                self.problemAlertMessage(message: noAccessMessage)
            }
        }
    }
    
    //check the access and status to the photo library before loading the view
    func photoLibraryImage() {
        let sourceType = UIImagePickerControllerSourceType.photoLibrary
        //get current status of photo library access
        let status = PHPhotoLibrary.authorizationStatus()
        //check if photo library available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            //message if no access
            let noAccessMessage = "Gridy needs access to your photo library to load an image"
            //handle status appropriately
            switch status {
            //if there is no permission set, request permission
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    //if permission is authorised call function that presents photo library view
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        //if permission denied call function that presents alert message to user
                        self.problemAlertMessage(message: noAccessMessage)
                    }
                })
            //if permission already held call function that presents photo library
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            //if permission denied call function that presents alert message to user
            case .restricted, .denied:
                self.problemAlertMessage(message: noAccessMessage)
            }
        }
    }
    
    //open the photo library or camera view
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        //open a photo library view for the user to choose an image
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //present the photo library
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //present an alert message if there is a problem with the camera or photo library
    func problemAlertMessage(message: String) {
        let alertController = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    //assign the chosen image to a variable and pass that to the image editor view controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //retrieve the image that was selected or taken by camera
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        //set the image to edit as the image from either the photo library or camera
        if let newImage = chosenImage {
            self.userChosenImage = newImage
        }
        //load the editor view controller only once the image picker view controller dismiss has completed to prevent conflicts
        picker.dismiss(animated:true, completion: {
            self.performSegue(withIdentifier: "EditorSegue", sender: nil)
        })
    }
    
    //closes image picker when user presses cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }

}

