//
//  Tile.swift
//  mahjongIOS
//
//  Created by Shruthilaya Jaganathan on 2020-07-01.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import Foundation

enum Suit: Int {
    case bam, crak, dot, flower, wind, joker

    func simpleDescription() -> String {
        switch self {
            case .crak:
                return "crak"
            case .bam:
                return "bam"
            case .dot:
                return "dot"
            case .flower:
                return ""
            case .joker:
                return ""
            case .wind:
                return "wind"
        }
    }
}

enum Rank: Int {
    case flower = 0
    case one, two, three, four, five, six, seven, eight, nine, dragon, north, east, west, south, joker

    func simpleDescription() -> String {
        switch self {
            case .flower:
                return "flower"
            case .one:
                return "one"
            case .two:
                return "two"
            case .three:
                return "three"
            case .four:
                return "four"
            case .five:
                return "five"
            case .six:
                return "six"
            case .seven:
                return "seven"
            case .eight:
                return "eight"
            case .nine:
                return "nine"
            case .dragon:
                return "dragon"
            case .north:
                return "north"
            case .east:
                return "east"
            case .west:
                return "west"
            case .south:
                return "south"
            case .joker:
                return "joker"
        }
    }
}

struct Tile: CustomStringConvertible, Equatable {
    let rank: Rank
    let suit: Suit

    var description: String {
        return "\(rank.simpleDescription())\n\(suit.simpleDescription())"
    }
    
    init(_ rank: Rank, _ suit: Suit) {
        self.rank = rank
        self.suit = suit
    }
    
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return (lhs.rank == rhs.rank) && (lhs.suit == rhs.suit)
    }
}
