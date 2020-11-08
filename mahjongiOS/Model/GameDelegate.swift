//
//  GameDelegate.swift
//  mahjongIOS
//
//  Created by Shruthilaya Jaganathan on 2020-07-02.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import Foundation

protocol GameDelegate {
    func didDiscardTile(tile: Tile, isComputerDiscarding: Bool)
    func didPickTile()
}

