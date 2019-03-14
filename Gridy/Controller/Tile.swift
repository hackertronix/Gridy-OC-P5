//
//  tile.swift
//  Gridy
//
//

import UIKit

//tile view overrides UIImageView to store some attributes with the tile
class Tile: UIImageView, UIGestureRecognizerDelegate {
    //attributes to hold with the tile view
    //the original position of the tile view in the tile holder
    var originalTileLocation: CGPoint
    //which location in the grid is its correct location
    var gridLocation: Int
    //whether the tile view is currently sat in it's correct location in the grid
    var inCorrectGridSpace: Bool
    
    init(originalLocation: CGPoint, frame: CGRect, finalGridLocation: Int) {
        self.originalTileLocation = originalLocation
        self.gridLocation = finalGridLocation
        self.inCorrectGridSpace = false
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
