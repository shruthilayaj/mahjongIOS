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
                return "flower"
            case .joker:
                return "joker"
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
        return "\(rank.simpleDescription()) \(suit.simpleDescription())"
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

class Hand: CustomStringConvertible {
    var tiles: [Tile] = []
    var exposedTiles: [Tile] = []
    
    func isValidForMahJong() -> Bool {
        if tiles.count != 14 {
            return false
        }
        else {
            return true
        }
    }
    
    var description: String {
        return "Tiles - \(tiles) \n Exposed Tiles - \(exposedTiles)"
    }
    
}

enum GameError: Error {
    case invalidDiscardIndex
}

enum IndecentExposure: Error {
    case differentTiles, tooFewTiles, tooManyTiles
}

struct Game {
    var possibleLines: [Line] = []
    var deck: [Tile] = []
    var hands: [Hand] = []
    
    init() {
        possibleLines = generateLines()
        possibleLines = possibleLines.map { (line) -> Line in
            Line(tiles: sortTiles(tiles: line.tiles))
        }
        deck = generateTiles()
        deal()
    }
    
    func generateLines() -> [Line] {
        let flower = Tile(Rank.flower, Suit.flower)
        let twoCrak = Tile(Rank.two, Suit.crak)
        let twoBam = Tile(Rank.two, Suit.bam)
        let twoDot = Tile(Rank.two, Suit.dot)
        let dragonDot = Tile(Rank.dragon, Suit.dot)
        let lines = [
            Line(tiles: [
                flower, flower, twoCrak, dragonDot, twoCrak, dragonDot, twoDot,
                twoDot, twoDot, twoDot, twoBam, twoBam, twoBam, twoBam,
            ]),
            Line(tiles: [
                flower, flower, twoBam, dragonDot, twoBam, dragonDot, twoDot,
                twoDot, twoDot, twoDot, twoCrak, twoCrak, twoCrak, twoCrak,
            ]),
            Line(tiles: [
                flower, flower, twoDot, dragonDot, twoDot, dragonDot, twoBam,
                twoBam, twoBam, twoBam, twoCrak, twoCrak, twoCrak, twoCrak,
            ]),
        ]
        
        return lines
    }
    
    func generateTiles() -> [Tile] {
        let flower = Tile(Rank.flower, Suit.flower)
        var tiles: [Tile] = []
        tiles.append(contentsOf: repeatElement(flower, count: 8))
        let suits = [Suit.bam, Suit.crak, Suit.dot]
        for suit in suits {
            for num in 1...10 {
                if let rank = Rank.init(rawValue: num) {
                    let tile = Tile(rank, suit)
                    tiles.append(contentsOf: repeatElement(tile, count: 4))
                }
            }
        }
        tiles.append(contentsOf: repeatElement(Tile(Rank.north, Suit.wind), count: 4))
        tiles.append(contentsOf: repeatElement(Tile(Rank.east, Suit.wind), count: 4))
        tiles.append(contentsOf: repeatElement(Tile(Rank.west, Suit.wind), count: 4))
        tiles.append(contentsOf: repeatElement(Tile(Rank.south, Suit.wind), count: 4))
        return tiles
        // TODO - add jokers
    }
    
    func sortTiles(tiles: [Tile]) -> [Tile] {
        // 2 crak, 3 bam
        let sortedTiles = tiles.sorted(by: {(tile1: Tile, tile2: Tile) -> Bool in
            if (tile1.rank.rawValue < tile2.rank.rawValue) {
                return true
            } else if (tile1.rank.rawValue > tile2.rank.rawValue) {
                return false
            } else {
                if (tile1.suit.rawValue < tile2.suit.rawValue) {
                    return true
                } else {
                    return false
                }
            }
        })
        return sortedTiles
    }
    
    func matchLine(hand: Hand) -> Bool {
        let sortedTiles = sortTiles(tiles: hand.tiles)
        for line in possibleLines {
            if line.tiles == sortedTiles {
                return true
            }
        }
        return false
    }
    
    mutating func deal() {
        deck.shuffle()
        for _ in 0...3 {
            let hand = Hand()
            for _ in 0...12 {
                hand.tiles.append(deck.popLast()!)
            }
            hands.append(hand)
        }
    }
    
    mutating func pickTile(hand: Hand) {
        hand.tiles.append(deck.popLast()!)
    }
    
    func discardTile(hand: Hand, tile: Tile) {
        if let index = hand.tiles.firstIndex(of: tile) {
            hand.tiles.remove(at: index)
        }
    }
    
    mutating func play() {
        var index = 0
        while deck.count > 0 {
            let hand = hands[index%4]
            pickTile(hand: hand)
            hand.tiles = sortTiles(tiles: hand.tiles)
            print("\(hand)")
            if let command = readLine() {
                switch command {
                case "D":
                    print("Please discard a tile from your hand...")
                    if let input = readLine() {
                        do {
                            if let safeIndex = Int(input) {
                                let tile = hand.tiles[Int(safeIndex)]
                                print("Discarding \(tile)...")
                                discardTile(hand: hand, tile: tile)
                            } else {
                                throw GameError.invalidDiscardIndex
                            }
                        } catch {
                            print(error)
                        }
                    }
                case "E":
                    print("Please select decent tiles to expose ...")
                    if let input = readLine() {
                        let tileIndices = input.split(separator: ",")
                        let tiles = tileIndices.map({hand.tiles[Int($0)!]})
                        do {
                            try expose(hand: hand, tiles: tiles)
                        } catch {
                            print(error)
                        }
                    }

                default:
                    print("invalid command ya fkn idiot")
                }
            }
            index += 1
        }
    }
    
    func expose(hand: Hand, tiles: [Tile]) throws {
        if !tiles.allSatisfy({$0 == tiles[0]}) {
            throw IndecentExposure.differentTiles
        }
        else if tiles.count < 3 {
            throw IndecentExposure.tooFewTiles
        } else if tiles.count > 5 {
            throw IndecentExposure.tooManyTiles
        }
        for tile in tiles {
            if let i = hand.tiles.firstIndex(of: tile) {
                hand.exposedTiles.append(tile)
                hand.tiles.remove(at: i)
            }
        }
    }
}

enum Rule: Int {
    case anyOneSuit, anyTwoSuits, anyThreeSuits, anyRun,

    func simpleDescription() -> String {
        switch self {
            case .anyOneSuit:
                return "anyOneSuit"
            case .anyTwoSuits:
                return "anyTwoSuits"
            case .anyThreeSuits:
                return "anyThreeSuits"
            case .anyRun:
                return "anyRun"
        }
    }
}

struct section2468 {
    let numFlower: Int
    let num2: Int
    let num4: Int
    let num6: Int
    let num8: Int
    let numDragon: Int
    
    let suitsMatch2: [Int]
    let suitsMatch4: [Int]
    let suitsMatch6: [Int]
    let suitsMatch8: [Int]
    let suitsMatchDragon: [Int]
    
    let suitsDiff2: [Int]
    let suitsDiff4: [Int]
    let suitsDiff6: [Int]
    let suitsDiff8: [Int]
    let suitsDiffDragon: [Int]
    
    func match(tiles: [Tile]) -> Bool {
        
    }
}

let line1 = section2468(numFlower: 4, num2: 1, num4: 2, num6: 3, num8: 4, numDragon: 0, suitsMatch2: [4, 6, 8], suitsMatch4: [2, 6, 8], suitsMatch6: [2, 4, 8], suitsMatch8: [2, 4, 6], suitsMatchDragon: [], suitsDiff2: [], suitsDiff4: [], suitsDiff6: [], suitsDiff8: [], suitsDiffDragon: [])

struct LineRules {
    
    func getTilesForLine(cardLine: [String], rules: [Rule]) -> Bool {
        <#function body#>
    }
    
    func validateAgainstCard(line: Line) -> Bool {
        cardLines = [[]]
    }
}

var game = Game()
game.play()
