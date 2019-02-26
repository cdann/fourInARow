//
//  BoardCollectionModelView.swift
//  fourinrowexperience
//
//  Created by celine dann on 14/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol ViewModel {
    associatedtype Input
    associatedtype Output
}

struct PieceSetup {
    let color: String?
    let debug: String
}

struct SectionOfPiece: SectionModelType {
    typealias Item = PieceSetup
    var items: [Item]
    
    init(original: SectionOfPiece, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(items: [Item]) {
        self.items = items
    }
}

class BoardCollectionViewModel: ViewModel {
    typealias Input = Board
    typealias Output = [SectionOfPiece]
    
    let input: BehaviorRelay<Input>
    let output: BehaviorSubject<Output>
    let disposeBag = DisposeBag()
    
    init(board: Input) {
        input = BehaviorRelay(value: board)
        output = BehaviorSubject(value:[])
        input.asObservable().map ({ (board) -> Output in
            return BoardCollectionViewModel.boardToCells(board: board)
        }).bind(to: output).disposed(by: disposeBag)
    }
    
    static func boardToCells(board: Board) -> [SectionOfPiece] {
        var x = 0
        var y = 0
        var n = 0
        let cellsSetup = board.rows.map { (row) -> SectionOfPiece in
            x = 0
            let rowSetup = row.map({ (state) -> PieceSetup in
                let color : String?
                switch state {
                case PieceColor.yellowCell:
                    color = "player yellow"
                case PieceColor.redCell:
                    color = "player red"
                default:
                    color = nil
                }
                let detail = "\(y) \(x)"
                x += 1
                n += 1
                return PieceSetup(color: color, debug: detail)
            })
            y += 1
            let items = [PieceSetup(color: nil, debug: "arrow")] + rowSetup
            return SectionOfPiece(items:items)
        }
        return cellsSetup
    }
    
}
