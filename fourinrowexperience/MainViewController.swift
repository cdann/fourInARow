//
//  MainViewController.swift
//  fourinrowexperience
//
//  Created by celine dann on 15/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    @IBOutlet weak var playerTurnLabel : UILabel!
    @IBOutlet weak var playerTurnView : UIView!
    var childController : BoardCollectionViewController?
    var viewModel: BoardCollectionViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.displayAlert()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let boardCtrl = segue.destination as? BoardCollectionViewController {
            self.childController = boardCtrl
            self.playerTurnLabel.text = ""
        }
    }
    
    private func initBoard(player1: String = "joueur1", player2: String = "joueur2") -> Board {
        let onTurnChange = {
            [weak self](playername: String, playerColor: UIColor, labelColor: UIColor) in
            self?.playerTurnLabel.text = "\(playername), your turn"
            self?.playerTurnLabel.textColor = labelColor
            self?.playerTurnView.backgroundColor = playerColor
        }
        let onWin : (String, UIColor) -> () = { [weak self](playername: String, playerColor: UIColor) in
            self?.displayAlert(winnerPseudo: playername)
            return
        }
        
        return Board(player1: player1, player2: player2, onTurnChange: onTurnChange, onWin: onWin)
    }
    
    private func displayAlert(winnerPseudo: String? = nil, cancel: Bool = false){
        let title = winnerPseudo == nil ? "Start a new game?" : "Congrats \(winnerPseudo!)!"
        let message = winnerPseudo == nil ? "Who will play?" : "Will you play the revenge?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField {[unowned self] (textfield) in
            textfield.placeholder = "Player one pseudo"
            textfield.text = self.viewModel?.input.value.playerNames[0]
        }
        alertController.addTextField {[unowned self] (textfield) in
            textfield.placeholder = "Player two pseudo"
            textfield.text = self.viewModel?.input.value.playerNames[1]
        }
        alertController.addAction(UIAlertAction(title: "Let's play", style: .default, handler: { [unowned self] (action) in
            self.letsPlayAlertAction(action: action, alertController: alertController)
        }))
        if cancel {
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        self.present(alertController, animated: true)
    }
    
    func letsPlayAlertAction(action: UIAlertAction, alertController: UIAlertController) {
        let pseudo1Field = alertController.textFields![0]
        let pseudo2Field = alertController.textFields![1]
        let board = self.initBoard(player1: pseudo1Field.text ?? "Player 1", player2: pseudo2Field.text ?? "Player 2")
        if (self.viewModel == nil) {
            self.viewModel = BoardCollectionViewModel(board: board)
            self.viewModel!.input.asObservable().subscribe(onNext: { (board) in
                let playerDetails = board.getCurrentUserDetails()
                self.playerTurnView.backgroundColor = playerDetails.color
                self.playerTurnLabel.text = "\(playerDetails.pseudo) your turn!"
                self.playerTurnLabel.textColor = playerDetails.labelColor
            }).disposed(by: self.viewModel!.disposeBag)
            self.childController?.setViewModel(viewModel: self.viewModel!)
        } else {
            self.viewModel?.input.accept(board)
        }
    }
    
    @IBAction func resetGame(_ sender: Any) {
        self.displayAlert(winnerPseudo: nil, cancel: true)
    }

}
