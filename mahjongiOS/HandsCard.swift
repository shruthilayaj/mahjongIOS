//
//  HandsCard.swift
//  mahjongiOS
//
//  Created by Shruthilaya Jaganathan on 2020-11-20.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import Foundation

struct HandsCard {
    func getCard() -> [CardLine] {

        var cardLines = [
            // 2468
            CardLine([LineSection([0, 0, 0, 0], 3), LineSection([2], 0), LineSection([4, 4], 0), LineSection([6, 6, 6], 0), LineSection([8, 8, 8, 8], 0)]),
            CardLine([LineSection([2, 2], 0), LineSection([4, 4], 0), LineSection([6, 6, 6], 1), LineSection([8, 8, 8], 1), LineSection([10, 10, 10, 10], 2)]),
            CardLine([LineSection([2, 2, 2, 2], 0), LineSection([4, 4, 4, 4], 0), LineSection([6, 6, 6, 6], 0), LineSection([8, 8], 0)]),
            CardLine([LineSection([2, 2, 2], 0), LineSection([4, 4, 4], 0), LineSection([6, 6, 6, 6], 1), LineSection([8, 8, 8, 8], 1)]),
            CardLine([LineSection([0, 0, 0, 0], 3), LineSection([4, 4, 4, 4], 0), LineSection([6, 6, 6, 6], 1), LineSection([2, 4], 2)]),
            CardLine([LineSection([0, 0, 0, 0], 3), LineSection([6, 6, 6, 6], 0), LineSection([8, 8, 8, 8], 1), LineSection([4, 8], 2)]),
            CardLine([LineSection([2, 2], 0), LineSection([4, 4, 4], 0), LineSection([4, 4], 1), LineSection([6, 6, 6], 1), LineSection([8, 8, 8, 8], 2)]),
            CardLine([LineSection([2, 2], 0), LineSection([4, 4, 4], 0), LineSection([10, 10, 10, 10], 0), LineSection([6, 6, 6], 0), LineSection([8, 8], 0)]),
            CardLine([LineSection([0, 0], 3), LineSection([2, 2, 2], 0), LineSection([4, 4, 4], 1), LineSection([6, 6, 6], 1), LineSection([8, 8, 8], 0)], true, 30),

        ]
        
        var i = 1
        while i < 10 {
            let n1 = i
            let n2 = i + 1
            let n3 = i + 2
            if n3 <= 9 {
                // consecutive run
                cardLines.append(CardLine([
                    LineSection([0, 0, 0, 0], 3), LineSection([n1, n1, n1, n1], 0), LineSection([n2, n2], 1), LineSection([n3, n3, n3, n3], 2),
                ]))
                cardLines.append(CardLine([
                    LineSection([n1, n1, n1], 0), LineSection([n2, n2, n2], 0), LineSection([n1, n1, n1], 1), LineSection([n2, n2, n2], 1), LineSection([n3, n3], 2),
                ]))
            }
            i += 1
        }
        return cardLines
    }

}
