//
//  ViewController.swift
//  mahjongIOS
//
//  Created by Shruthilaya Jaganathan on 2020-07-01.
//  Copyright © 2020 Shruthilaya Jaganathan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameDelegate {
    @IBOutlet weak var tile1: UIButton!
    @IBOutlet weak var tile2: UIButton!
    @IBOutlet weak var tile3: UIButton!
    @IBOutlet weak var tile4: UIButton!
    @IBOutlet weak var tile5: UIButton!
    @IBOutlet weak var tile6: UIButton!
    @IBOutlet weak var tile7: UIButton!
    @IBOutlet weak var tile8: UIButton!
    @IBOutlet weak var tile9: UIButton!
    @IBOutlet weak var tile10: UIButton!
    @IBOutlet weak var tile11: UIButton!
    @IBOutlet weak var tile12: UIButton!
    @IBOutlet weak var tile13: UIButton!
    @IBOutlet weak var tile14: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var discardLabel: UILabel!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var exposeButton: UIButton!
    @IBOutlet weak var exchangeButton: UIButton!
    @IBOutlet weak var mahJongButton: UIButton!
    
    var game: Game? = nil
    var selectedIndexes: [Int] = []
    var discardState = true
    var hand: Hand? = nil
    var tileButtons: [UIButton] = []
    var currentPlayer = 0
    
    fileprivate func syncTileButtons() {
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
            index += 1
        }
        for tile in hand!.exposedTiles {
            let tileButton = tileButtons[index]
            tileButton.tag = index
            tileButton.setTitle("\(tile)", for: .normal)
            tileButton.backgroundColor = UIColor.systemYellow
            tileButton.isHidden = false
            index += 1
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        game = Game()
        game!.delegate = self
        hand = game!.hands[0]
        tileButtons = [tile1, tile2, tile3, tile4, tile5, tile6, tile7, tile8, tile9, tile10, tile11, tile12, tile13, tile14]
        syncTileButtons()
        discardButton.isEnabled = false
        passButton.isEnabled = false
        callButton.isEnabled = false
        exchangeButton.isEnabled = false
        exposeButton.isEnabled = false
    }
    
    @IBAction func tileSelected(_ sender: Any) {
        let button = sender as! UIButton
        let tileIndex = button.tag
        if discardState && selectedIndexes.count > 0 && !button.isSelected {
            let alert = UIAlertController(title: "Error", message: "Select single tile to discard", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if !selectedIndexes.contains(tileIndex){
            selectedIndexes.append(tileIndex)
            button.isSelected = true
            if discardState && selectedIndexes.count == 1 && hand!.tileCount == 14 {
                discardButton.isEnabled = true
            }
        } else {
            selectedIndexes.remove(at: selectedIndexes.firstIndex(of: tileIndex)!)
            button.isSelected = false
            discardButton.isEnabled = false
        }
        print("\(selectedIndexes)")
    }
    
    
    @IBAction func discardButtonPressed(_ sender: Any) {
        let discardedTile = hand!.tiles[selectedIndexes[0]]
        game!.discardTile(tile: discardedTile)
        syncTileButtons()
        discardButton.isEnabled = false
        let tileButton = tileButtons[selectedIndexes.remove(at: 0)]
        tileButton.isSelected = false
        mahJongButton.isEnabled = false
    }
    
    func didPickTile() {
        syncTileButtons()
        callButton.isEnabled = false
        passButton.isEnabled = false
        mahJongButton.isEnabled = true
    }
    
    func didDiscardTile(tile: Tile, isComputerDiscarding: Bool) {
        discardLabel.text = "\(tile)"
        if isComputerDiscarding {
            callButton.isEnabled = true
            passButton.isEnabled = true
        }
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
    
    
    @IBAction func sortByRankPressed(_ sender: UIButton) {
        game!.sortHand(sortByRank: true)
        syncTileButtons()
    }
    
    @IBAction func sortBySuitPressed(_ sender: UIButton) {
        game!.sortHand(sortByRank: false)
        syncTileButtons()
    }
}
