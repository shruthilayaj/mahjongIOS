import Foundation

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


let text = """
FF|3,2020|0,2222|1,2222|2
FFFF|3,2|0,44|0,666|0,8888|0
22|0,44|0,666|1,888|1,DDDD|2
"""

let array = text.components(separatedBy: "\n")

let rankMap = ["F": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "D": 10, "N": 11, "E": 12, "W": 13, "S": 14]

var cardLines: [CardLine] = []
for line in array {
    var sections: [LineSection] = []
    for section in line.components(separatedBy: ",") {
        let section_ = section.components(separatedBy: "|")
        let ranks = Array(section_[0])
        let suit = section_[1]
        let rank = rankMap[String(ranks[0])]!
        var sectionRanks: [Int] = []
        sectionRanks.append(contentsOf: repeatElement(rank, count: ranks.count))
        sections.append(LineSection(sectionRanks, Int(suit)!))
    }
    cardLines.append(CardLine(sections))
}

print(cardLines)
