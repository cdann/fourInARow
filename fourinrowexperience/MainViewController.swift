//
//  MainViewController.swift
//  fourinrowexperience
//
//  Created by celine dann on 15/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var playerTurnLabel : UILabel!
    @IBOutlet weak var playerTurnView : UIView!
    var childController : BoardCollectionViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let boardCtrl = segue.destination as? BoardCollectionViewController {
            self.childController = boardCtrl
            let board = initBoard()
            boardCtrl.viewModel = BoardCollectionModelView(input: board)
            let details = board.getCurrentUserDetails()
            self.playerTurnLabel.text = "\(details.pseudo), your turn"
        }
    }
    
    private func initBoard(player1:String = "joueur1", player2:String = "joueur2") -> Board {
        let onTurnChange = {
            [weak self](playername:String, playerColor: UIColor, labelColor: UIColor) in
            self?.playerTurnLabel.text = "\(playername), your turn"
            self?.playerTurnLabel.textColor = labelColor
            self?.playerTurnView.backgroundColor = playerColor
        }
        let onWin = { [weak self](playername:String, playerColor: UIColor) in return }
        return Board(player1: player1, player2: player2, onTurnChange: onTurnChange, onWin: onWin)
    }
    
    @IBAction func resetGame(_ sender: Any) {
        childController?.viewModel?.input = initBoard()
    }

}
