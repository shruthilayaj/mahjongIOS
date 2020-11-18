//
//  ViewController.swift
//  mahjongIOS
//
//  Created by Shruthilaya Jaganathan on 2020-07-01.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameDelegate {
    @IBOutlet weak var tile1: TileButton!
    @IBOutlet weak var tile2: TileButton!
    @IBOutlet weak var tile3: TileButton!
    @IBOutlet weak var tile4: TileButton!
    @IBOutlet weak var tile5: TileButton!
    @IBOutlet weak var tile6: TileButton!
    @IBOutlet weak var tile7: TileButton!
    @IBOutlet weak var tile8: TileButton!
    @IBOutlet weak var tile9: TileButton!
    @IBOutlet weak var tile10: TileButton!
    @IBOutlet weak var tile11: TileButton!
    @IBOutlet weak var tile12: TileButton!
    @IBOutlet weak var tile13: TileButton!
    @IBOutlet weak var tile14: TileButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var discardLabel: UILabel!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var exposeButton: UIButton!
    @IBOutlet weak var exchangeButton: UIButton!
    @IBOutlet weak var mahJongButton: UIButton!
    @IBOutlet weak var numTilesRemaining: UILabel!
    
    var game: Game? = nil
    var selectedIndexes: [Int] = []
    var discardState = true
    var hand: Hand? = nil
    var tileButtons: [TileButton] = []
    var currentPlayer = 0
    
    fileprivate func syncTileButtons() {
        // Displays the tile in the order specified in hand.tiles.
        // Call this function when order or contents of hand.tiles
        // change.
        var index = 0
        _ = tileButtons.map({
            $0.isHidden = true
            $0.backgroundColor = UIColor.systemBackground
        })
        for tile in hand!.tiles{
            let tileButton = tileButtons[index]
            tileButton.tag = index
            tileButton.setTitle("\(tile)", for: .normal)
            tileButton.isHidden = false
            tileButton.isExposed = false
            index += 1
        }
        for tile in hand!.exposedTiles {
            let tileButton = tileButtons[index]
            tileButton.tag = index
            tileButton.setTitle("\(tile)", for: .normal)
            tileButton.backgroundColor = UIColor.systemYellow
            tileButton.isHidden = false
            tileButton.isExposed = true
            index += 1
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Why are we not initializing game in the ViewController?
        game = Game()
        game!.delegate = self
        hand = game!.hands[0]
        tileButtons = [tile1, tile2, tile3, tile4, tile5, tile6, tile7, tile8, tile9, tile10, tile11, tile12, tile13, tile14]
        syncTileButtons()

        // Tracking the allowed state transitions.
        discardButton.isEnabled = false
        passButton.isEnabled = false
        callButton.isEnabled = false
        exchangeButton.isEnabled = false
        exposeButton.isEnabled = false
    }
    
    @IBAction func tileSelected(_ button: TileButton) {
        // This IBAction is connected to all the Tile buttons.
        exchangeButton.isEnabled = false
        discardButton.isEnabled = false
        let tileIndex = button.tag
        if discardState && selectedIndexes.count == 1 && !button.isSelected {
            let previous_selection = tileButtons[selectedIndexes[0]]
            let isSwapping = button.isExposed != previous_selection.isExposed
            if isSwapping {
                selectedIndexes.append(tileIndex)
                button.isSelected = true
                exchangeButton.isEnabled = true
                
                return
            }
            else {
                previous_selection.isSelected = false
                selectedIndexes.remove(at: selectedIndexes.firstIndex(of: previous_selection.tag)!)
            }
        }


        if !selectedIndexes.contains(tileIndex){
            if discardState && selectedIndexes.count == 2 {
                button.shake()
                return
            }
            selectedIndexes.append(tileIndex)
            button.isSelected = true
        // Deselecting a tile.
        // TODO: Investigate if there's a better setting for de/selecting.
        } else {
            selectedIndexes.remove(at: selectedIndexes.firstIndex(of: tileIndex)!)
            button.isSelected = false
        }
        
        if discardState && selectedIndexes.count == 1 && hand!.tileCount == 14 && !tileButtons[selectedIndexes[0]].isExposed {
            discardButton.isEnabled = true
        }
        print("\(selectedIndexes)")
    }
    
    
    @IBAction func discardButtonPressed(_ sender: Any) {
        let discardedTile = hand!.tiles[selectedIndexes[0]]
        game!.discardTile(tile: discardedTile)
        syncTileButtons()
        discardButton.isEnabled = false
        exchangeButton.isEnabled = false
        let tileButton = tileButtons[selectedIndexes.remove(at: 0)]
        tileButton.isSelected = false
        mahJongButton.isEnabled = false
    }
    
    func didPickTile(tilesRemaining: Int, isComputerPicking: Bool) {
        if !isComputerPicking {
            syncTileButtons()
            callButton.isEnabled = false
            passButton.isEnabled = false
            mahJongButton.isEnabled = true
        }
        numTilesRemaining.text = "Remaining Tiles: \(tilesRemaining)"
    }
    
    func didDiscardTile(tile: Tile, isComputerDiscarding: Bool) {
        discardLabel.text = "\(tile)"
        if isComputerDiscarding {
            callButton.isEnabled = true
            passButton.isEnabled = true
        }
    }
    
    func didExchangeTile() {
        syncTileButtons()
        discardButton.isEnabled = false
        exchangeButton.isEnabled = false
    }
    
    @IBAction func passButtonPressed(_ sender: UIButton) {
        print("Passing on discarded tile...")
        game!.passDiscardedTile()
    }
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
        print("Calling discarded tile...")
        callButton.isEnabled = false
        passButton.isEnabled = false
        exposeButton.isEnabled = true
        discardState = false
    }

    @IBAction func exposeButtonPressed(_ sender: UIButton) {
        var selectedTiles: [Tile] = []
        for i in selectedIndexes{
            selectedTiles.append(hand!.tiles[i])
        }
        do {
            try game!.expose(hand: hand!, tiles: selectedTiles)
            syncTileButtons()
            for i in selectedIndexes {
                let button = tileButtons[i]
                button.isSelected = false
            }
            selectedIndexes = []
            discardState = true
            exposeButton.isEnabled = false
            mahJongButton.isEnabled = true
        } catch {
            let alert = UIAlertController(title: "Indecent Exposure", message: "\(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .default))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel expose", comment: "Default action"), style: .default, handler: { (_) in
                self.callButton.isEnabled = true
                self.passButton.isEnabled = true
                self.exposeButton.isEnabled = false
                self.discardState = true
                for i in self.selectedIndexes {
                    let button = self.tileButtons[i]
                    button.isSelected = false
                }
                self.selectedIndexes = []
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func mahJongDeclared(_ sender: UIButton) {
        do {
            try game!.declareMahJong()
            let alert = UIAlertController(title: "Congratulations!", message: "You bloody genius", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Play again", comment: "Default action"), style: .default, handler: {(_) in self.viewDidLoad()}))
            self.present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Game Error", message: "\(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }


    @IBAction func exchangeButtonPressed(_ sender: Any) {
        var handTile: Tile?
        var exposedTile: Tile?

        for index in selectedIndexes {
            let tileButton = tileButtons[selectedIndexes.remove(at: 0)]
            tileButton.isSelected = false
            if tileButton.isExposed {
                let exposedHand = game!.hands[0]
                let exposedHandTiles = exposedHand.tiles + exposedHand.exposedTiles
                exposedTile = exposedHandTiles[index]
            } else {
                handTile = hand!.tiles[index]
            }
        }
        
        // TODO: Add option to exchange with other players

        do {
            try self.game!.exchange(tile: handTile!, exposedTile: exposedTile!)
        } catch {
            // TODO: Implement a toast instead of an alert
            let alert = UIAlertController(title: "Game Error", message: "\(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    @IBAction func sortByRankPressed(_ sender: UIButton) {
        game!.sortHand(sortByRank: true)
        syncTileButtons()
    }
    
    @IBAction func sortBySuitPressed(_ sender: UIButton) {
        game!.sortHand(sortByRank: false)
        syncTileButtons()
    }
}

extension UIView {
    // Using SpringWithDamping
    func shake(duration: TimeInterval = 0.5, xValue: CGFloat = 12, yValue: CGFloat = 0) {
        self.transform = CGAffineTransform(translationX: xValue, y: yValue)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)

    }
}
