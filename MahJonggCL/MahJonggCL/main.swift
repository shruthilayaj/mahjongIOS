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

struct LineSection {
    let ranks: [Int]
    let suit: Int
    
    init(_ ranks: [Int], _ suit: Int) {
        self.ranks = ranks
        self.suit = suit
    }
}

struct Game {
    var possibleLines: [Line] = []
    var deck: [Tile] = []
    var hands: [Hand] = []
    var discardedTile: Tile? = nil
    
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
    
    func validateAgainstLine(cardLine: [LineSection], line: Line) -> Bool {
        var numJokers = 0
        let joker = Tile(Rank.joker, Suit.joker)
        for tile in line.tiles {
            if tile == joker {
                numJokers += 1
            }
        }
        
        let suitCombinations = [
            [Suit.bam, Suit.crak, Suit.dot],
            [Suit.dot, Suit.bam, Suit.crak],
            [Suit.crak, Suit.dot, Suit.bam],
            [Suit.crak, Suit.bam, Suit.dot],
            [Suit.dot, Suit.crak, Suit.bam],
            [Suit.bam, Suit.dot, Suit.crak],
        ]
        for suitCombination in suitCombinations {
            var tempLine = line
            var matchTile = true
            var tempNumJokers = numJokers
            for section in cardLine {
//                print("Section \(section)")
                let (rank, suit) = (section.ranks, section.suit)
//                var tiles: [Tile] = []
                for r in rank {
                    var tile: Tile
                    if suit < 3 {
                        let suitEnum = suitCombination[suit]
                        tile = Tile(Rank(rawValue: r)!, suitEnum)
                    } else {
                        tile = Tile(Rank(rawValue: r)!, Suit(rawValue: suit)!)
                    }
                    if let index = tempLine.tiles.firstIndex(of: tile) {
//                            print("Removing tile \(tile)")
                        tempLine.tiles.remove(at: index)
                    } else {
                        if rank.count > 2 && tempNumJokers > 0 {
                            tempLine.tiles.remove(at: tempLine.tiles.firstIndex(of: joker)!)
                            tempNumJokers -= 1
                        } else {
//                            print("Tile \(tile) not found")
                            matchTile = false
                            break
                        }
                    }
                }
                
                
                if !matchTile {
                    break
                }
                
                if tempLine.tiles.count == 0 {
                    return true
                }
                
            }
        }
        return false
    }
    
    func getCard(tiles: [Tile]) -> [[LineSection]] {
        var cardLines = [
            [LineSection([0, 0, 0, 0], 3), LineSection([2], 0), LineSection([4, 4], 0), LineSection([6, 6, 6], 0), LineSection([8, 8, 8, 8], 0)],
            [LineSection([2, 2], 0), LineSection([4, 4], 0), LineSection([6, 6, 6], 1), LineSection([8, 8, 8], 1), LineSection([10, 10, 10, 10], 2)],
            [LineSection([0, 0, 0, 0], 3), LineSection([4, 4, 4, 4], 0), LineSection([6, 6, 6, 6], 1), LineSection([2, 4], 2)],
        ]
        
        var minNum = 10
        for tile in tiles {
            let rankInt = tile.rank.rawValue
            if rankInt > 0 && rankInt < minNum {
                minNum = rankInt
            }
        }
        if minNum <= 7 {
            let n1 = minNum
            let n2 = minNum + 1
            let n3 = minNum + 2
            cardLines.append([
                LineSection([0, 0, 0, 0], 3), LineSection([n1, n1, n1, n1], 0), LineSection([n2, n2], 1), LineSection([n3, n3, n3, n3], 2),
            ])
            cardLines.append([
                LineSection([n1, n1, n1], 0), LineSection([n2, n2, n2], 0), LineSection([n1, n1, n1], 1), LineSection([n2, n2, n2], 1), LineSection([n3, n3], 2),
            ])
        }
        
        return cardLines
    }
    
    func validateAgainstCard(line: Line) -> Bool {
        let cardLines = getCard(tiles: line.tiles)
        for cardLine in cardLines {
            let pass = validateAgainstLine(cardLine: cardLine, line: line)
            if pass {
                return  true
            }
        }
        return false
    }
    
//    func validateExposedTiles(exposedTiles: [[Tile]]) -> Bool {
//        var exposedSections = []
//        for exposedGroup in exposedTiles {
//            let tile = exposedGroup.first(where: {$0 != joker})!
//
//        }
//        let staticLines = getCard(tiles: [])
//        for staticLine in staticLines {
//
//        }
//
//    }
    
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
                                discardedTile = tile
                                discardTile(hand: hand, tile: tile)
                            } else {
                                throw GameError.invalidDiscardIndex
                            }
                        } catch {
                            print(error)
                        }
                    }
                case "C":
                    print("Please select decent tiles to expose...")
                    if let input = readLine() {
                        let tileIndices = input.split(separator: ",")
                        var tiles = tileIndices.map({hand.tiles[Int($0)!]})
                        tiles.append(discardedTile!)
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
        let joker = Tile(Rank.joker, Suit.joker)
        if !tiles.allSatisfy({$0 == tiles[0] || $0 == joker}) {
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


var lineRules = Game()
let flower = Tile(Rank.flower, Suit.flower)
let twoCrak = Tile(Rank.two, Suit.crak)
let fourCrak = Tile(Rank.four, Suit.crak)
let sixCrak = Tile(Rank.six, Suit.crak)
let eightCrak = Tile(Rank.eight, Suit.crak)
let sixBam = Tile(Rank.six, Suit.bam)
let eightBam = Tile(Rank.eight, Suit.bam)
let dotDragon = Tile(Rank.dragon, Suit.dot)

let twoDot = Tile(Rank.two, Suit.dot)
let fourDot = Tile(Rank.four, Suit.dot)
let joker = Tile(Rank.joker, Suit.joker)
let productLine = Line(tiles: [joker, flower, joker, flower, fourCrak, fourCrak, fourCrak, fourCrak, sixBam, sixBam, sixBam, sixBam, twoDot, fourDot])
var pass = lineRules.validateAgainstCard(line: productLine)
print(pass)
let badProductLine = Line(tiles: [flower, flower, flower, flower, fourCrak, fourCrak, fourCrak, fourCrak, sixBam, sixBam, sixBam, sixBam, twoDot, joker])
pass = lineRules.validateAgainstCard(line: badProductLine)
print(pass)

let fiveBam = Tile(Rank.five, Suit.bam)
let goodRunHand = Line(tiles: [flower, flower, flower, flower, fourDot, fourDot, fourDot, fourDot, fiveBam, fiveBam, sixCrak, sixCrak, sixCrak, sixCrak])
print(lineRules.validateAgainstCard(line: goodRunHand))
let badRunHand = Line(tiles: [flower, flower, flower, flower, fourDot, fourDot, fourDot, fourDot, fiveBam, fiveBam, sixCrak, sixCrak, sixCrak, twoDot])
print(lineRules.validateAgainstCard(line: badRunHand))
