//
//  BoardCollectionModelView.swift
//  fourinrowexperience
//
//  Created by celine dann on 14/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import UIKit

protocol ModelView {
    associatedtype Input
    associatedtype Output
}

class BoardCollectionModelView: ModelView {
    typealias Input = Board
    typealias Output = [[(color:UIColor, detail:String)]]
    var input : Input {
        didSet {
            self.output = BoardCollectionModelView.computeCellArray(input: self.input)
            self.onChange?()
        }
    }
    var output : Output
    var onChange : (() -> ())?
    
    init(input : Input) {
        self.input = input
        self.output = BoardCollectionModelView.computeCellArray(input: self.input)
        self.onChange?()
    }
    
    class func computeCellArray(input:Input) -> Output {
        var x = 0
        var y = 0
        var n = 0
        let cellsSetup = input.rows.map { (row) -> [(color:UIColor, detail:String)] in
            x = 0
            let rowSetup = row.map({ (state) -> (color:UIColor, detail:String) in
                let color : UIColor!
                switch state {
                case PieceState.yellowCell:
                    color = UIColor.init(named: "player yellow")
                case PieceState.redCell:
                    color = UIColor.init(named: "player red")
                default:
                    color = UIColor.clear
                }
                let detail = "\(y) \(x)"
                x += 1
                n += 1
                return (color:color, detail:detail)
            })
            y += 1
            return rowSetup
        }
        return cellsSetup
    }
    
    func playInCell(section: Int, index : Int) {
        input.play(rowIndex: section)
        self.output = BoardCollectionModelView.computeCellArray(input: self.input)
        onChange?()
    }
    
}
