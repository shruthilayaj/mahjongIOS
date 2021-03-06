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
    case invalidDiscardIndex, invalidExchangeTile
}

enum IndecentExposure: Error {
    case differentTiles, tooFewTiles, tooManyTiles, noMatchingLines
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
        let tile = deck.popLast()!
        print("Picking up \(tile)")
        hand.tiles.append(tile)
    }
    
    func discardTile(hand: Hand, tile: Tile) {
        if let index = hand.tiles.firstIndex(of: tile) {
            hand.tiles.remove(at: index)
        }
    }
    
    func validateAgainstLine(cardLine: [LineSection], line: Line, forExposed: Bool = false) -> Bool {
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
            var tempNumJokers = numJokers
              for section in cardLine {
                    let (rank, suit) = (section.ranks, section.suit)
//                    var matchTile = true
                    var rankIndex = 0
                    for r in rank {
                        var tile: Tile
                        if suit < 3 {
                            let suitEnum = suitCombination[suit]
                            tile = Tile(Rank(rawValue: r)!, suitEnum)
                        } else {
                            tile = Tile(Rank(rawValue: r)!, Suit(rawValue: suit)!)
                        }
                        if let index = tempLine.tiles.firstIndex(of: tile) {
                            tempLine.tiles.remove(at: index)
                        } else {
                            if rank.count > 2 && tempNumJokers > 0 {
                                if (forExposed && rankIndex > 0) || !forExposed {
                                    tempLine.tiles.remove(at: tempLine.tiles.firstIndex(of: joker)!)
                                    tempNumJokers -= 1
                                } else {
                                    break
                                }
                            } else {
//                                matchTile = false
                                break
                            }
                        }
                        rankIndex += 1
                    }

                
//                    if tempLine.tiles.count == 0 && matchTile {
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
        
        var i = 1
        while i < 10 {
            let n1 = i
            let n2 = i + 1
            let n3 = i + 2
            if n3 <= 9 {
                cardLines.append([
                    LineSection([0, 0, 0, 0], 3), LineSection([n1, n1, n1, n1], 0), LineSection([n2, n2], 1), LineSection([n3, n3, n3, n3], 2),
                ])
                cardLines.append([
                    LineSection([n1, n1, n1], 0), LineSection([n2, n2, n2], 0), LineSection([n1, n1, n1], 1), LineSection([n2, n2, n2], 1), LineSection([n3, n3], 2),
                ])
            }
            i += 1
        }
        return cardLines
    }
    
    func validateAgainstCard(line: Line) -> [[LineSection]] {
        let cardLines = getCard(tiles: line.tiles)
        var validLines: [[LineSection]] = []
        for cardLine in cardLines {
            let pass = validateAgainstLine(cardLine: cardLine, line: line)
            if pass {
                validLines.append(cardLine)
            }
        }
        return validLines
    }
    
    func validLines(exposedTiles: [Tile]) -> [[LineSection]] {
        let cardLines = getCard(tiles: exposedTiles)
        var validLines: [[LineSection]] = []
        for cardLine in cardLines {
            let pass = validateAgainstLine(cardLine: cardLine, line: Line(tiles: exposedTiles), forExposed: true)
            if pass {
                validLines.append(cardLine)
            }
        }
        return validLines
    }
    
    mutating func play(initialTiles: [Tile] = []) {
        if initialTiles.count == 13 {
            let hand = Hand()
            hand.tiles = initialTiles
            hands[0] = hand
        }
        var index = 0
        while deck.count > 0 {
            var hand = hands[index]
            if let command = readLine() {
                switch command {
                case "P":
                    pickTile(hand: hand)
                    hand.tiles = sortTiles(tiles: hand.tiles)
                    print("Player \(index) - \(hand)")
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
                    index += 1
                    index = index % 4
                case "C":
                    print("Which player is calling?")
                    let oldIndex = index
                    index = Int(readLine()!)!
                    hand = hands[index]
                    print("Player \(index) calling \(discardedTile!), hand \(hand)")
                    print("Please select decent tiles to expose...")
                    if let input = readLine() {
                        let tileIndices = input.split(separator: ",")
                        print("DEBUG - \(tileIndices), \(hand)")
                        let tiles = tileIndices.map({hand.tiles[Int($0)!]})
                        do {
                            try expose(hand: hand, tiles: tiles, calledTile: discardedTile!)
                        } catch {
                            print("ERROR - \(error), cancelling call")
                            index = oldIndex
                        }
                    }
                case "X":
                    print("Which player would you like to exchange with?")
                    let exposedIndex = Int(readLine()!)!
                    let exposedHand = hands[exposedIndex]
                    let destinationHand = hands[index]
                    print("Which tile would you like to exchange?")
                    if let input = readLine() {
                        let tile = destinationHand.tiles[Int(input)!]
                        do {
                            try exchange(tile: tile, exposedHand: exposedHand, destinationHand: destinationHand)
                        } catch {
                            print("\(error)")
                        }
                    }

                default:
                    print("invalid command ya fkn idiot")
                }
            }
        }
    }
    
    func expose(hand: Hand, tiles: [Tile], calledTile: Tile) throws {
        let joker = Tile(Rank.joker, Suit.joker)
        if tiles.count < 3 {
            throw IndecentExposure.tooFewTiles
        } else if tiles.count > 5 {
            throw IndecentExposure.tooManyTiles
        } else if !tiles.allSatisfy({$0 == calledTile || $0 == joker}) {
            throw IndecentExposure.differentTiles
        } else if validLines(exposedTiles: tiles + [calledTile]).count == 0 {
            throw IndecentExposure.noMatchingLines
        }
        hand.exposedTiles.append(calledTile)
        for tile in tiles {
            if let i = hand.tiles.firstIndex(of: tile) {
                hand.exposedTiles.append(tile)
                hand.tiles.remove(at: i)
            
            }
        }
        print("finished exposing, updated hand - \(hand)")
    }
    
    func exchange(tile: Tile, exposedHand: Hand, destinationHand: Hand) throws {
        if !exposedHand.exposedTiles.contains(tile) {
            throw GameError.invalidExchangeTile
        }
        let joker = Tile(Rank.joker, Suit.joker)
        if let i = exposedHand.exposedTiles.firstIndex(of: joker) {
            let exposedJoker = exposedHand.exposedTiles.remove(at: i)
            exposedHand.exposedTiles.append(tile)
            destinationHand.tiles.append(exposedJoker)
            destinationHand.tiles.remove(at: destinationHand.tiles.firstIndex(of: tile)!)
        }
        print("Exchange complete - destinationHand \(destinationHand), exposedHand \(exposedHand)")
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
let goodRunHand = Line(tiles: [flower, flower, flower, flower, joker, joker, joker, joker, fiveBam, fiveBam, sixCrak, sixCrak, sixCrak, sixCrak])
print(lineRules.validateAgainstCard(line: goodRunHand))
let badRunHand = Line(tiles: [flower, flower, flower, flower, fourDot, fourDot, fourDot, fourDot, fiveBam, fiveBam, sixCrak, sixCrak, sixCrak, twoDot])
print(lineRules.validateAgainstCard(line: badRunHand))

let exposedTiles = [flower, flower, flower, flower, joker, eightBam, eightBam, eightBam]
print(lineRules.validLines(exposedTiles: exposedTiles))


let exposedTiles2 = [sixBam, sixBam, sixBam]
print(lineRules.validLines(exposedTiles: exposedTiles2))

let southWind = Tile(Rank.south, Suit.wind)
let initialTiles = [flower, flower, flower, fourDot, fourDot, fourDot, sixBam, sixBam, joker, twoCrak, fourCrak, southWind, southWind]
var game = Game()
//game.play(initialTiles: initialTiles)


