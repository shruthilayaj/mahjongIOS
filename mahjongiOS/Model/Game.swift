//
//  Game.swift
//  mahjongIOS
//
//  Created by Shruthilaya Jaganathan on 2020-07-01.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import Foundation

enum GameError: Error {
    case invalidDiscardIndex, invalidExchangeTile, noMatchingLines
}

enum IndecentExposure: Error {
    case differentTiles, tooFewTiles, tooManyTiles, noMatchingLines
}



struct Game {
    var possibleLines: [Line] = []
    var deck: [Tile] = []
    var hands: [Hand] = []
    var discardedTile: Tile? = nil
    var delegate: GameDelegate?
    var currentPlayer = 0
    
    init() {
        deck = generateTiles()
        deal()
        let flower = Tile(Rank.flower, Suit.flower)
        let twoCrak = Tile(Rank.two, Suit.crak)
        let eightCrak = Tile(Rank.eight, Suit.crak)
        let sixDot = Tile(Rank.six, Suit.dot)
        let fourDot = Tile(Rank.four, Suit.dot)
        let joker = Tile(Rank.joker, Suit.joker)
        let southWind = Tile(Rank.south, Suit.wind)
        let initialTiles = [flower, flower, fourDot, fourDot, fourDot, sixDot, sixDot, joker, twoCrak, twoCrak, eightCrak, southWind, southWind, joker]
        hands[0].tiles = initialTiles
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
        // TODO: Add jokers
    }
    
    func sortTiles(tiles: [Tile], sortByRank: Bool = true) -> [Tile] {
        // 2 crak, 3 bam
        let sortedTiles = tiles.sorted(by: {(tile1: Tile, tile2: Tile) -> Bool in
            let value1 = sortByRank ? tile1.rank.rawValue : tile1.suit.rawValue
            let value2 = sortByRank ? tile2.rank.rawValue : tile2.suit.rawValue
            let tiebreakValue1 = sortByRank ? tile1.suit.rawValue : tile1.rank.rawValue
            let tiebreakValue2 = sortByRank ? tile2.suit.rawValue : tile2.rank.rawValue
            if value1 == value2 {
                return tiebreakValue1 < tiebreakValue2
            } else {
                return value1 < value2
            }
        })
        return sortedTiles
    }
    
    mutating func sortHand(sortByRank: Bool) {
        let hand = hands[currentPlayer]
        hand.tiles = sortTiles(tiles: hand.tiles, sortByRank: sortByRank)
    }
    
    mutating func deal() {
        deck.shuffle()
        for i in 0...3 {
            let hand = Hand()
            for _ in 0...12 {
                hand.tiles.append(deck.popLast()!)
            }
            if i == 0 {
                hand.tiles.append(deck.popLast()!)
            }
            hands.append(hand)
        }
    }
    
    mutating func pickTile(hand: Hand){
        let tile = deck.popLast()!
        print("Picking up \(tile)")
        hand.tiles.append(tile)
        let isComputerPicking = currentPlayer != 0
        let tilesRemaining = deck.count
        delegate?.didPickTile(tilesRemaining: tilesRemaining, isComputerPicking: isComputerPicking)
    }
    
    mutating func discardTile(tile: Tile) {
        if let index = hands[currentPlayer].tiles.firstIndex(of: tile) {
            print("discardTile - \(tile), \(currentPlayer)")
            discardedTile = hands[currentPlayer].tiles.remove(at: index)
            let isComputerDiscarding = currentPlayer != 0
            delegate?.didDiscardTile(tile: tile, isComputerDiscarding: isComputerDiscarding)

            if !isComputerDiscarding {
                currentPlayer = (currentPlayer + 1)%4
                print("Calling discardRandomTile tile from discardTile for \(currentPlayer)")
                discardRandomTile()
            }
        }
    }
    
    mutating func discardRandomTile() {
        pickTile(hand: hands[currentPlayer])
        discardTile(tile: hands[currentPlayer].tiles.randomElement()!)
    }
    
    mutating func passDiscardedTile() {
        let lastComputerDiscarding = currentPlayer == 3
        currentPlayer = (currentPlayer + 1)%4
        if !lastComputerDiscarding {
            print("calling discardRandomTile tile from passDiscardedTile")
            discardRandomTile()
        } else {
            pickTile(hand: hands[currentPlayer])
        }
        
    }
    
    func validateAgainstLine(cardLine: CardLine, tiles: [Tile], forExposed: Bool = false) -> Bool {
        var numJokers = 0
        let joker = Tile(Rank.joker, Suit.joker)
        for tile in tiles {
            if tile == joker {
                numJokers += 1
            }
        }
        
        if forExposed && cardLine.concealed {
            return false
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
            var tempTiles = tiles
            var tempNumJokers = numJokers
            for section in cardLine.sections {
                    let (rank, suit) = (section.ranks, section.suit)
                    var matchTile = true
                    var rankIndex = 0
                    for r in rank {
                        var tile: Tile
                        if suit < 3 {
                            let suitEnum = suitCombination[suit]
                            tile = Tile(Rank(rawValue: r)!, suitEnum)
                        } else {
                            tile = Tile(Rank(rawValue: r)!, Suit(rawValue: suit)!)
                        }
                        if let index = tempTiles.firstIndex(of: tile) {
                            tempTiles.remove(at: index)
                        } else {
                            if rank.count > 2 && tempNumJokers > 0 {
                                if (forExposed && rankIndex > 0) || !forExposed {
                                    tempTiles.remove(at: tempTiles.firstIndex(of: joker)!)
                                    tempNumJokers -= 1
                                } else {
                                    break
                                }
                            } else {
                                matchTile = false
                                break
                            }
                        }
                        rankIndex += 1
                    }

                    if tempTiles.count == 0 && matchTile {
                        return true
                    }
                    
                }
            }
        return false
    }
    
    func validateExposedAgainstLine(cardLine: CardLine, exposedGroups: [[Tile]]) -> Bool {
        
        
        if cardLine.concealed {
            return false
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
            for section in cardLine.sections {
                    let (rank, suit) = (section.ranks, section.suit)
                    var matchTile = true
                    var rankIndex = 0
                    var tempExposedGroups = exposedGroups
                    for exposedGroup in tempExposedGroups {
                        var numJokers = 0
                        let joker = Tile(Rank.joker, Suit.joker)
                        for tile in exposedGroup {
                            if tile == joker {
                                numJokers += 1
                            }
                        }
                        var tempTiles = exposedGroup
                        for r in rank {
                            var tile: Tile
                            if suit < 3 {
                                let suitEnum = suitCombination[suit]
                                tile = Tile(Rank(rawValue: r)!, suitEnum)
                            } else {
                                tile = Tile(Rank(rawValue: r)!, Suit(rawValue: suit)!)
                            }
                            if let index = tempTiles.firstIndex(of: tile) {
                                tempTiles.remove(at: index)
                            } else {
                                if rank.count > 2 && numJokers > 0 {
                                    if rankIndex > 0 {
                                        tempTiles.remove(at: tempTiles.firstIndex(of: joker)!)
                                        numJokers -= 1
                                    } else {
                                        break
                                    }
                                } else {
                                    matchTile = false
                                    break
                                }
                            }
                            rankIndex += 1
                        }
                        if tempTiles.count == 0 && matchTile {
                            return true
                        }
                    }
                    
                }
            }
        return false
    }
    
//    func getCard(tiles: [Tile]) -> [CardLine] {
//        var cardLines = [
//            // 2468
//            CardLine([LineSection([0, 0, 0, 0], 3), LineSection([2], 0), LineSection([4, 4], 0), LineSection([6, 6, 6], 0), LineSection([8, 8, 8, 8], 0)]),
//            CardLine([LineSection([2, 2], 0), LineSection([4, 4], 0), LineSection([6, 6, 6], 1), LineSection([8, 8, 8], 1), LineSection([10, 10, 10, 10], 2)]),
//            CardLine([LineSection([2, 2, 2, 2], 0), LineSection([4, 4, 4, 4], 0), LineSection([6, 6, 6, 6], 0), LineSection([8, 8], 0)]),
//            CardLine([LineSection([2, 2, 2], 0), LineSection([4, 4, 4], 0), LineSection([6, 6, 6, 6], 1), LineSection([8, 8, 8, 8], 1)]),
//            CardLine([LineSection([0, 0, 0, 0], 3), LineSection([4, 4, 4, 4], 0), LineSection([6, 6, 6, 6], 1), LineSection([2, 4], 2)]),
//            CardLine([LineSection([0, 0, 0, 0], 3), LineSection([6, 6, 6, 6], 0), LineSection([8, 8, 8, 8], 1), LineSection([4, 8], 2)]),
//            CardLine([LineSection([2, 2], 0), LineSection([4, 4, 4], 0), LineSection([4, 4], 1), LineSection([6, 6, 6], 1), LineSection([8, 8, 8, 8], 2)]),
//            CardLine([LineSection([2, 2], 0), LineSection([4, 4, 4], 0), LineSection([10, 10, 10, 10], 0), LineSection([6, 6, 6], 0), LineSection([8, 8], 0)]),
//            CardLine([LineSection([0, 0], 3), LineSection([2, 2, 2], 0), LineSection([4, 4, 4], 1), LineSection([6, 6, 6], 1), LineSection([8, 8, 8], 0)], true, 30),
//
//        ]
//
//        var i = 1
//        while i < 10 {
//            let n1 = i
//            let n2 = i + 1
//            let n3 = i + 2
//            if n3 <= 9 {
//                // consecutive run
//                cardLines.append(CardLine([
//                    LineSection([0, 0, 0, 0], 3), LineSection([n1, n1, n1, n1], 0), LineSection([n2, n2], 1), LineSection([n3, n3, n3, n3], 2),
//                ]))
//                cardLines.append(CardLine([
//                    LineSection([n1, n1, n1], 0), LineSection([n2, n2, n2], 0), LineSection([n1, n1, n1], 1), LineSection([n2, n2, n2], 1), LineSection([n3, n3], 2),
//                ]))
//            }
//            i += 1
//        }
//        return cardLines
//    }
    
    func validateAgainstCard() -> [CardLine] {
        let hand = hands[currentPlayer]
        let tiles = hand.tiles + hand.exposedTiles
        let cardLines = HandsCard().getCard()
        var validLines: [CardLine] = []
        for cardLine in cardLines {
            let pass = validateAgainstLine(cardLine: cardLine, tiles: tiles)
            if pass {
                validLines.append(cardLine)
            }
        }
        return validLines
    }
    
    func validLines(exposedTiles: [Tile]) -> [CardLine] {
        let cardLines = HandsCard().getCard()
        var validLines: [CardLine] = []
        for cardLine in cardLines {
            let pass = validateAgainstLine(cardLine: cardLine, tiles: exposedTiles, forExposed: true)
            if pass {
                validLines.append(cardLine)
            }
        }
        print(validLines)
        return validLines
    }
    
    func declareMahJong() throws {
        let validLines = validateAgainstCard()
        if validLines.count == 0 {
            throw GameError.noMatchingLines
        }
    }
    
    mutating func expose(hand: Hand, tiles: [Tile]) throws {
        let calledTile = discardedTile!
        let joker = Tile(Rank.joker, Suit.joker)
        if tiles.count < 2 {
            throw IndecentExposure.tooFewTiles
        // TODO: Implement quints
        } else if tiles.count > 4 {
            throw IndecentExposure.tooManyTiles
        } else if !tiles.allSatisfy({$0 == calledTile || $0 == joker}) {
            throw IndecentExposure.differentTiles
        } else if validLines(exposedTiles: tiles + [calledTile] + hand.exposedTiles).count == 0 {
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
        currentPlayer = 0
        
    }
    
    func exchange(tile: Tile, exposedTile: Tile) throws {
        let destinationHand = hands[currentPlayer]
        /*
            TODO: Add support for exchange with computers. We would need
                to track which hand a particular tile belongs to.
        */
        let joker = Tile(Rank.joker, Suit.joker)
        if exposedTile != joker {
            throw GameError.invalidExchangeTile
        }
        let exposedHand = hands[0]
        if !exposedHand.exposedTiles.contains(tile) {
            throw GameError.invalidExchangeTile
        }
        if let i = exposedHand.exposedTiles.firstIndex(of: joker) {
            let exposedJoker = exposedHand.exposedTiles.remove(at: i)
            exposedHand.exposedTiles.append(tile)
            destinationHand.tiles.append(exposedJoker)
            destinationHand.tiles.remove(at: destinationHand.tiles.firstIndex(of: tile)!)
            delegate?.didExchangeTile()
        }
        print("Exchange complete - destinationHand \(destinationHand), exposedHand \(exposedHand)")
    }
}
