//
//  Card.swift
//  mahjongiOS
//
//  Created by Shruthilaya Jaganathan on 2020-11-29.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import Foundation
import Keys

class Card {
    static func encryptDecrypt(_ input: String) -> String {
        let keys = MahjongiOSKeys()

        let key = keys.cardSecret.map { $0 }
        let length = key.count
        var output = ""

        for i in input.enumerated() {
            let byte = [i.element.utf8() ^ key[i.offset % length].utf8()]
            output.append(String(bytes: byte, encoding: .utf8)!)
        }

        return output
    }

    func getCard() -> [CardLine] {
        var cardLines: [CardLine] = []
        let path = Bundle.main.path(forResource: "Card2020Encrypted", ofType: "txt")
        do {
            var text = try String(contentsOfFile: path!)
            text = Card.encryptDecrypt(text)
            let array = text.components(separatedBy: "\n")

            let rankMap = ["F": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "D": 10, "N": 11, "E": 12, "W": 13, "S": 14, "0": 10]

            for line in array {
                if line.count == 0 {
                        continue
                    }
                var i = 1
                lineLoop: while i < 10 {
                    let n1 = i
                    let n2 = i + 1
                    let n3 = i + 2
                    let n4 = i + 3
                    let n5 = i + 4
                    let consecutiveMap = ["a": n1, "b": n2, "c": n3, "d": n4, "e": n5]
                    if (line.contains("e") && n5 > 9) || (line.contains("d") && n4 > 9) || (line.contains("c") && n3 > 9) || (line.contains("b") && n2 > 9) || (line.contains("a") && n1 > 9) {
                        break lineLoop
                    }
                    var sections: [LineSection] = []
                    var sectionComponents = line.components(separatedBy: ",")
                    let lineValue = sectionComponents.popLast()!.components(separatedBy: "|")
                    let concealed = lineValue[0] == "C"
                    let points = Int(lineValue[1])
                    for section in sectionComponents {
                        let section_ = section.components(separatedBy: "|")
                        let ranks = Array(section_[0])
                        let suit = section_[1]
                        let rank = consecutiveMap[String(ranks[0])] ?? rankMap[String(ranks[0])]
                        var sectionRanks: [Int] = []
                        sectionRanks.append(contentsOf: repeatElement(rank!, count: ranks.count))
                        sections.append(LineSection(sectionRanks, Int(suit)!))
                    }
                    cardLines.append(CardLine(sections, concealed, points!))
                    if !line.contains("a") {
                        break lineLoop  // Breaks if not a consecutive run or like numbers
                    }
                    i += 1
                }
            }
            return cardLines
        }
        catch(_){print("error")}

        return cardLines

    }
}

import Foundation

extension Character {
    func utf8() -> UInt8 {
        let utf8 = String(self).utf8
        return utf8[utf8.startIndex]
    }
}
