//
//  Line.swift
//  mahjongIOS
//
//  Created by Shruthilaya Jaganathan on 2020-07-01.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import Foundation

struct Line {
    var tiles: [Tile]  // (repeating count: 14)
    
}

struct LineSection {
    let ranks: [Int]
    let suit: Int
    
    init(_ ranks: [Int], _ suit: Int) {
        self.ranks = ranks
        self.suit = suit
    }
}

struct CardLine {
    let sections: [LineSection]
    let concealed: Bool
    let points: Int
    
    init(_ sections: [LineSection], _ concealed: Bool = false, _ points: Int = 25) {
        self.sections = sections
        self.concealed = concealed
        self.points = points
    }
}

