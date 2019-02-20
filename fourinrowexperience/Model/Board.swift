//
//  File.swift
//  fourinrowexperience
//
//  Created by celine dann on 14/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import UIKit

enum PieceColor {
    case yellowCell
    case redCell
    case emptyCell
}

class Board {
    static let numberOfRows = 7
    static let numberOfLines = 6
    
    var playerNames : [String]
    var yellowTurn : Bool = false
    var rows : [[PieceColor]]
    var winCells : [(row : Int, line : Int)] = []
    let onTurnChange : (String, UIColor, UIColor) -> ()
    let onWin : ((String, UIColor) -> ())?
    
    init(player1 : String = "player1", player2 : String = "player2", onTurnChange: @escaping (String, UIColor, UIColor) -> (), onWin : @escaping (String, UIColor) -> ()) {
        rows = Array.init(repeating: 1, count: Board.numberOfRows).map({ (_) -> [PieceColor] in
            return Array.init(repeating: 1, count: Board.numberOfLines).map({ (_) -> PieceColor in
                return PieceColor.emptyCell
            })
        })
        playerNames = [player1, player2]
        self.onTurnChange = onTurnChange
        self.onWin = onWin
    }
    
    init(source: Board){
        playerNames = source.playerNames
        yellowTurn = source.yellowTurn
        rows = source.rows
        winCells = source.winCells
        onWin = source.onWin
        onTurnChange = source.onTurnChange
    }
    
    init(){
        playerNames = ["", ""]
        rows = Array.init(repeating: 1, count: Board.numberOfRows).map({ (_) -> [PieceColor] in
            return Array.init(repeating: 1, count: Board.numberOfLines).map({ (_) -> PieceColor in
                return PieceColor.emptyCell
            })
        })
        onWin = {(_, _) in return}
        onTurnChange = {(_, _, _) in return}
    }
    
    func play(rowIndex:Int) {
        var lowestemptyIndex : Int?
        for cell in rows[rowIndex] {
            if cell != .emptyCell {
                break
            }
            lowestemptyIndex = lowestemptyIndex == nil ? 0 : lowestemptyIndex! + 1
        }
        guard let lowestIndex = lowestemptyIndex else {
            return
        }
        rows[rowIndex][lowestIndex] = self.getCurrentUserPiece()
        checkWin(posPlay: (row:rowIndex, line:lowestIndex))
        
        yellowTurn = !yellowTurn
        let userDetails = getCurrentUserDetails()
        onTurnChange(userDetails.pseudo, userDetails.color, userDetails.labelColor)
    }
    
    
    func play(asSource rowIndex:Int) -> Board {
        var lowestemptyIndex : Int?
        let board = Board(source: self)
        for cell in rows[rowIndex] {
            if cell != .emptyCell {
                break
            }
            lowestemptyIndex = lowestemptyIndex == nil ? 0 : lowestemptyIndex! + 1
        }
        guard let lowestIndex = lowestemptyIndex else {
            return self
        }
        board.rows[rowIndex][lowestIndex] = self.getCurrentUserPiece()
        board.checkWin(posPlay: (row:rowIndex, line:lowestIndex))
        
        board.yellowTurn = !yellowTurn
        let userDetails = getCurrentUserDetails()
        board.onTurnChange(userDetails.pseudo, userDetails.color, userDetails.labelColor)
        return board
    }
    
    // player1 : player[0] yellowTurn(false) red
    // player2 : player[1] yellowTurn(true) yellow
    func getCurrentUserPiece() -> PieceColor {
        return yellowTurn ? .yellowCell : .redCell
    }
    
    func getCurrentUserPseudo() -> String {
        return yellowTurn ? playerNames[1] : playerNames[0]
    }
    
    func getCurrentUserDetails() -> (pseudo: String, color: UIColor, labelColor: UIColor) {
        let pseudoIndex = yellowTurn ? 1 : 0
        let colorName = yellowTurn ? "player yellow" : "player red"
        let labelColor = yellowTurn ? UIColor(named: "neutral grey") : UIColor.white
        return (pseudo: playerNames[pseudoIndex], color: UIColor(named: colorName)!, labelColor : labelColor!)
    }
    
    //Check victory
    
    typealias PosInBoard = (row : Int, line : Int)
    
    func checkAxe(refCell: PosInBoard, indexesToCheck: [Int], getPosFromIndex : (_ index: Int) -> PosInBoard) -> [PosInBoard] {
        let pieceColor = rows[refCell.row][refCell.line]
        var stopCount = false
        return indexesToCheck.reduce([refCell]) {
            (checkCells, index) -> [(row : Int, line : Int)] in
            let posCheck = getPosFromIndex(index)
            let checkRow = 0 <= posCheck.row && posCheck.row < Board.numberOfRows
            let checkLine = 0 <= posCheck.line && posCheck.line < Board.numberOfLines
            let posColor = checkRow && checkLine ? rows[posCheck.row][posCheck.line] : nil
            if index == 0 {
                stopCount = false
            } else if posColor == nil || posColor != pieceColor {
                stopCount = true
            } else if !stopCount {
                var newWinCells = checkCells
                newWinCells.append(posCheck)
                return newWinCells
            }
            return checkCells
        }
    }
    
    func checkHorizontal(line: Int) -> Bool {
        let mandatoryRowToWin = 3
        // If this position in the line is empty no one can win the line
        if rows[mandatoryRowToWin][line] == .emptyCell { return false }
        let refCell = (row : mandatoryRowToWin, line : line)
        let checkCells = checkAxe(refCell: refCell, indexesToCheck: [-1, -2, -3, 0, 1, 2, 3]) {
            return (row: refCell.row + $0, line: refCell.line)
        }
        if checkCells.count >= 4 {
            self.winCells = checkCells
            return true
        }
        return false
    }
    
    func checkVertical(row: Int) -> Bool {
        let mandatoryLineToWin = 2
        // If this position in the row is empty no one can win the row
        if rows[row][mandatoryLineToWin] == .emptyCell { return false }
        let refCell = (row : row, line : mandatoryLineToWin)
        let indexesToCheck = [-1, -2, 0, 1, 2, 3]
        let checkCells = checkAxe(refCell: refCell, indexesToCheck: indexesToCheck) {
            return (row: refCell.row, line: refCell.line + $0)
        }
        if checkCells.count >= 4 {
            self.winCells = checkCells
            return true
        }
        return false
    }
    
    func checkDiagonalTopRight(pos: PosInBoard) -> Bool {
        let mandatoryLineToWin = 2
        let diffLine = pos.line - mandatoryLineToWin
        // If this position is empty no one can win the diagonals
        let refCell = (row: pos.row + diffLine, line: mandatoryLineToWin)
        // No winning diagonal going to top right reaches (row:0, line:3)
        let checkRefCellMaxMin = refCell.row < Board.numberOfRows && refCell.row >= 0
        if !checkRefCellMaxMin || rows[refCell.row][refCell.line] == .emptyCell || pos.row < 1 { return false }
        let indexesToCheck = [-1, -2, -3, 0, 1, 2]
        let checkCells = checkAxe(refCell: refCell, indexesToCheck: indexesToCheck) {
            return (row: refCell.row + $0, line: refCell.line - $0)
        }
        if checkCells.count >= 4 {
            self.winCells = checkCells
            return true
        }
        return false
    }
    
    func checkDiagonalTopLeft(pos: PosInBoard) -> Bool {
        let mandatoryLineToWin = 2
        let diffLine = pos.line - mandatoryLineToWin
        // If this position is empty no one can win the diagonals
        let refCell = (row: pos.row - diffLine, line: mandatoryLineToWin)
        let checkRefCellMaxMin = refCell.row < Board.numberOfRows && refCell.row >= 0
        // No winning diagonal going to bottom right reaches (row:6, line:3)
        if  !checkRefCellMaxMin || rows[refCell.row][refCell.line] == .emptyCell || pos.row > 5 { return false }
        let indexesToCheck = [-1, -2, 0, 1, 2, 3]
        let checkCells = checkAxe(refCell: refCell, indexesToCheck: indexesToCheck) {
            return (row: refCell.row + $0, line: refCell.line + $0)
        }
        if checkCells.count >= 4 {
            self.winCells = checkCells
            return true
        }
        return false
    }
    
    func checkWin(posPlay : PosInBoard) {
        let winCase: () -> () = {
            let userDetails = self.getCurrentUserDetails()
            self.onWin?(userDetails.pseudo, userDetails.color)
        }
        if self.checkVertical(row: posPlay.row) { winCase(); return; }
        if self.checkHorizontal(line: posPlay.line) { winCase(); return; }
        if self.checkDiagonalTopLeft(pos: posPlay) { winCase(); return; }
        if self.checkDiagonalTopRight(pos: posPlay) { winCase(); return;}
    }
    
}
