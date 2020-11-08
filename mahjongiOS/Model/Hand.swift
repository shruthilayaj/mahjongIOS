//
//  Hand.swift
//  mahjongIOS
//
//  Created by Shruthilaya Jaganathan on 2020-07-01.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import Foundation

class Hand: CustomStringConvertible {
    var tiles: [Tile] = []
    var exposedTiles: [Tile] = []
    
    func isValidForMahJong() -> Bool {
        if tileCount != 14 {
            return false
        }
        else {
            return true
        }
    }
    
    var description: String {
        return "Tiles - \(tiles) \n Exposed Tiles - \(exposedTiles)"
    }
    
    var tileCount: Int {
        return tiles.count + exposedTiles.count
    }
    
}
