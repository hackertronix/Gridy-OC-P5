//
//  GameViewController.swift
//  Gridy
////  Created by Luke G on 04/04/2018.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    //MARK: Variables
    var gameImage : UIImage!
    let defaults = UserDefaults.standard
    //Int to hold the size of the grid
    var gridSize : Int!
    //an array of UIImage arrays to hold the image tiles
    var imageArr = [UIImage]()
    //holds position of view to use when pan gesture recogniser handled
    var initialImageViewOffset = CGPoint()
    //variable for move counter label
    @IBOutlet weak var moveCounter: UILabel!
    var moves = 0
    var scoringStreak = 0
    var score = 0
    //variable for view and sub view containing tiles
    @IBOutlet weak var tileHolderView: UIView!
    @IBOutlet weak var containingView: UIView!
    //variable for grid view
    @IBOutlet weak var gridView: UIImageView!
    //array for holding grid locations
    var gridLocations: [CGPoint] = []
    //array for tile views
    var tileViews: [Tile] = []
    //sound management variables
    @IBOutlet weak var soundButton: UIButton!
    var soundOn : Bool = true
    var audioPlayer : AVAudioPlayer?
    //views for the peek function
    let imageView = UIImageView()
    let previewHoldingView = UIView()
    
    //MARK: View setup
    override func viewDidLoad() {
        super.viewDidLoad()
        splitImage(gridSize: gridSize)
        getGridLocations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveProgress() {

    }

    //change score label
    func updateMoveCounter(correctMove: Bool) {
        //increase the number of moves
        moves += 1
        //check if the move was a correct one
        if correctMove == false {
            //for incorrect moves reset the scoring streak and remove a point (unless at 0 points)
            scoringStreak = 0
            if score > 0 {
                score -= 1
            }
        } else {
            //for correct score increment the scoring streak and update the score
            scoringStreak += 1
            score += scoringStreak
        }
        //update the score label
        moveCounter.text = String(format: "%03d", score)
    }

    //send the game image and final move number to the game complete view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameCompleteSegue" {
            let vc = segue.destination as! GameCompleteViewController
            vc.gameImage = gameImage   
            vc.movesCompleted = moves
            vc.score = score
        }
    }
    
    //present a preview of the image when the user presses peek
    @IBAction func peekButtonPressed(_ sender: Any) {
        //set the view image as the game image
        imageView.image = gameImage
        //add the view and set it's size and location properties
        self.view.addSubview(previewHoldingView)
        self.previewHoldingView.addSubview(imageView)
        //stretch the view to near the edges of the screen
        var imageViewSideSize = 0.0
        var previewViewSideSize = 0.0
        if self.view.frame.height > self.view.frame.width {
            imageViewSideSize = Double(self.view.frame.width) - 30.0
            previewViewSideSize = Double(self.view.frame.width) - 20.0
        } else {
            //for landscape mode
            imageViewSideSize = Double(self.view.frame.height) - 30.0
            previewViewSideSize = Double(self.view.frame.height) - 20.0
        }
        self.previewHoldingView.frame = CGRect(x: 0.0, y: 0.0, width: previewViewSideSize, height: previewViewSideSize)
        self.imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageViewSideSize, height: imageViewSideSize)
        self.previewHoldingView.backgroundColor = UIColor.black
        //center the image view
        self.imageView.center = self.previewHoldingView.center
        self.previewHoldingView.center = CGPoint(x: self.view.center.x - self.view.frame.width, y: self.view.center.y)
        self.view.bringSubview(toFront: self.previewHoldingView)
        //animate the presentation in
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.previewHoldingView.center = self.view.center
        }) { (success) in }
        //animate the presentation out (2 sec delay)
        UIView.animate(withDuration: 0.4, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.previewHoldingView.center = CGPoint(x: self.view.center.x + self.view.frame.width, y: self.view.center.y)
        }) { (success) in }
    }
    
    //MARK: Sound management
    @IBAction func soundButtonPressed(_ sender: Any) {
        //change the status of the sound button when it's pressed
        if soundButton.isSelected {
            soundButton.isSelected = false
        } else {
            soundButton.isSelected = true
        }
    }
    
    //play a sound using the filename passed to the function
    func playSound(Sound: String) {
        let path = Bundle.main.path(forResource: Sound, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // couldn't load file :(
            print("no sound file")
        }
    }
    
    
    //MARK: Grid Management
    //identify the points in superview for the top left corners of each space in the grid
    func getGridLocations() {
        //determine height of tiles using
        let height =  (gridView.frame.height) /  CGFloat (gridSize)
        let width =  (gridView.frame.width)  / CGFloat (gridSize)
        //iterate through the number of rows/columns to create the tile and add it to the array
        for y in 0..<gridSize{
            for x in 0..<gridSize{
                //create an image context the size of one tile
                UIGraphicsBeginImageContextWithOptions(
                    CGSize(width:width, height:height),
                    false, 0)
                //using the ful size image create a cropped image using the height and width variables and the iterated place in the grid
                let location =  CGPoint.init(x: CGFloat(x) * width, y:  CGFloat(y) * height)
                let locationInSuperview = gridView.convert(location, to: gridView.superview)
                //add location to array of locations
                gridLocations.append(locationInSuperview)
            }
        }
    }
    
    //identifies if the tile is near a grid location and returns the grid position it is near or returns false if not near
    func isTileNearGrid(finalPosition: CGPoint) -> (Bool, Int) {
        //iterate through grid locations to identify distance between tile and grid location
        for x in 0..<gridLocations.count {
            let gridPoint = gridLocations[x]
        //for gridPoint in gridLocations {
            //create from and to points
            var fromX = finalPosition.x
            var toX = gridPoint.x
            var fromY = finalPosition.y
            var toY = gridPoint.y
            //where final position is greater than gridpoint swap from and to points
            if finalPosition.x > gridPoint.x {
                fromX = gridPoint.x
                toX = finalPosition.x
            }
            if finalPosition.y > gridPoint.y {
                fromY = gridPoint.y
                toY = finalPosition.y
            }
            //calculate distance from point and how close it needs to be to snap to grid
            let distance = (fromX - toX) * (fromX - toX) + (fromY - toY) * (fromY - toY)
            let halfTileSideSize = (gridView.frame.height / CGFloat(gridSize))/2.0
            //check if the tile is near a grid location
            if distance < (halfTileSideSize * halfTileSideSize) {
                //valid move update move counter
                return (true, x)
            }
        }
        //not close enough to snap to grid
        return (false, 99)
    }
    
//MARK: Gesture recognisers
    //move the image when the pan gesture is used
    @objc func moveImage(_ sender: UIPanGestureRecognizer) {
        //bring the tile to the front of the view so it doesn't disappear behind other views when moving
        sender.view?.superview?.bringSubview(toFront: sender.view!)
        //start the translation
        let translation = sender.translation(in: sender.view?.superview)
        if sender.state == .began {
            initialImageViewOffset = (sender.view?.frame.origin)!
        }
        //set new position
        let position = CGPoint(x: translation.x + initialImageViewOffset.x - (sender.view?.frame.origin.x)!, y: translation.y + initialImageViewOffset.y - (sender.view?.frame.origin.y)!)
        //identifies position in superview
        let positionInSuperview = sender.view?.convert(position, to: sender.view?.superview)
        //transform the view using the new position
        sender.view?.transform = (sender.view?.transform.translatedBy(x: position.x, y: position.y))!
        //identify where final location of tile should be within superview once gesture ended
        if sender.state == .ended {
            //identify if tile near a grid position
            let (nearTile, snapPosition) = isTileNearGrid(finalPosition: positionInSuperview!)
            let v = sender.view as! Tile
            if nearTile {
                //if its near a tile snap it to the grid
                sender.view?.frame.origin = gridLocations[snapPosition]
                //play correct move sound
                if soundButton.isSelected != true {
                    playSound(Sound: "Right.mp3")
                }
                //if the grid position matches the correct image location mark the image as in the correct place
                if String(snapPosition) == sender.view?.accessibilityLabel {
                    //mark tile as in correct space
                    v.inCorrectGridSpace = true
                    //update the score
                    updateMoveCounter(correctMove: true)
                    
                } else {
                    //mark tile as not in correct space
                    v.inCorrectGridSpace = false
                    //update the score
                    updateMoveCounter(correctMove: false)
                    
                }
            } else {
                //if not near grid position return to holding location also allows tile to be swiped out
                sender.view?.frame.origin = v.originalTileLocation
                v.inCorrectGridSpace = false
                //play wrong sound
                if soundButton.isSelected != true {
                    playSound(Sound: "Wrong.mp3")
                }
            }
            //check if the game has been completed
            checkIfGameComplete()
        }
    }
    
    //MARK: Game Complete
    func checkIfGameComplete() {
        if allTilesInCorrectPosition() {
            //segue to game complete scene
            self.performSegue(withIdentifier: "GameCompleteSegue", sender: nil)
        }
    }
    
    func allTilesInCorrectPosition() -> Bool {
        //iterate through tile views and find if any still in wrong position
        for tile in tileViews {
            if tile.inCorrectGridSpace == false {
                //if a tile found in wrong place return false
                return false
            }
        }
        //if no tiles found in wrong position return true
        return true
    }
    
//MARK: Tile Views
    //create imageviews for each tile and space out evenly in the tile holder view
    func createTiles() {
        //number of tiles in the final image
        let numberOfTiles = 16 //gridSize^2
        //the size of each side of the tile, tiles are square so all sides same
        let tileSideSize = gridView.frame.height / CGFloat(gridSize)
        let tileSideSizeWithGap = tileSideSize + 5.0
        //calculate the number of tiles that will fit across and down in the tile holder view
        let columns = Int((tileHolderView.frame.width / tileSideSizeWithGap).rounded(.down))
        let rows = Int((tileHolderView.frame.height / tileSideSizeWithGap).rounded(.down))
        let numberOfTilesThatCanFit = columns * rows
        //check that all the tiles can fit in the space
        if numberOfTiles > numberOfTilesThatCanFit {
            //handle what to do if tiles don't fit
            print("More tiles than space")
        } else {
            var imageNumber = 0
            //creates a temporary array that holds a number to represent each index number in the image array
            var imagePositionsArray = Array(0...(imageArr.count-1))
            for y in 0..<rows {
                for x in 0..<columns{
                    //make sure we're only adding views whilst there are tiles to add views for
                    if imageNumber < numberOfTiles {
                        //sets the CGRect for the image view moving the image view position to space them out in the container
                        let xLocation = CGFloat(x) * (tileSideSizeWithGap)
                        let yLocation = CGFloat(y) * (tileSideSizeWithGap)
                        let tileRect = CGRect.init(x: xLocation, y: yLocation, width: tileSideSize, height: tileSideSize)
                        //initialises the image view with the rect
                        let tile = Tile(originalLocation: CGPoint(x: xLocation, y: yLocation),frame: tileRect, finalGridLocation: imageNumber)
                        //adds the tile view as a sub view to the view containing the tile holder view and the grid view
                        containingView.addSubview(tile)
                        //find a random index number to retrieve an image so the tiles are in a shuffled order
                        let randomNumber = arc4random_uniform(UInt32(imagePositionsArray.count))
                        //remove the index number so a duplicate tile isn't created
                        let imageIndexNumber = imagePositionsArray.remove(at: Int(randomNumber))
                        //initialise the tile with image from the index chosen randomly
                        tile.image = imageArr[imageIndexNumber]
                        tile.isUserInteractionEnabled = true
                        //set the label of the view to match the image index 0->max working left to right top to bottom
                        tile.accessibilityLabel = "\(imageIndexNumber)"
                        //set up the gesture recognizers
                        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImage(_:)))
                        //set gesture recognizer delegates
                        panGestureRecognizer.delegate = self
                        tile.addGestureRecognizer(panGestureRecognizer)
                        //append the view to the view array
                        tileViews.append(tile)
                    }
                    imageNumber += 1
                }
            }
        }
    }
    
    //splits an image into a number of tiles based on grid size
    func splitImage(gridSize : Int){
        //load game image
        let oImg = gameImage
        //determine height of tiles using
        let height =  (gameImage.size.height) /  CGFloat (gridSize)
        let width =  (gameImage.size.width)  / CGFloat (gridSize)
        //scale conversion factor is needed as UIImage make use of "points" whereas CGImage use pixels.
        let scale = (gameImage.scale)
        //iterate through the number of rows/columns to create the tile and add it to the array
        for y in 0..<gridSize{
            for x in 0..<gridSize{
                //create an image context the size of one tile
                UIGraphicsBeginImageContextWithOptions(
                    CGSize(width:width, height:height),
                    false, 0)
                //using the ful size image create a cropped image using the height and width variables and the iterated place in the grid
                let i =  oImg?.cgImage?.cropping(to:  CGRect.init(x: CGFloat(x) * width * scale, y:  CGFloat(y) * height * scale  , width: width * scale  , height: height * scale) )
                //initialize the image context with cropped image
                let newImg = UIImage.init(cgImage: i!)
                //append the image to the array
                imageArr.append(newImg)
                //needed to end the image context
                UIGraphicsEndImageContext();
            }
        }
        createTiles()
    }
    
}
