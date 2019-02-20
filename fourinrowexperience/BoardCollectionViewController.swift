//
//  BoardCollectionViewController.swift
//  fourinrowexperience
//
//  Created by celine dann on 14/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources


class BoardCollectionViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionview : UICollectionView!
    let disposeBag = DisposeBag()
    let datasource: RxCollectionViewSectionedReloadDataSource<SectionOfPiece> = RxCollectionViewSectionedReloadDataSource<SectionOfPiece>(
        configureCell: { (dataSource, collectionView, indexPath, pieceSetUp) -> UICollectionViewCell in
        let identifier = indexPath.row > 0 ? "emptyCell" : "redArrow"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if indexPath.row > 0{
            cell.backgroundColor = pieceSetUp.color == nil ? UIColor.clear : UIColor(named: pieceSetUp.color!)
        }
        return cell
    })
    var datasObservable: Observable<[SectionOfPiece]> = Observable.just([])
    
    func setViewModel(viewModel: BoardCollectionViewModel) {
        let datasObservable = viewModel.output.asObservable()
        let reactiveCollection: Reactive<UICollectionView> = self.collectionview.rx
        datasObservable.bind(to: reactiveCollection.items(dataSource: datasource)).disposed(by: disposeBag)
        reactiveCollection.itemSelected.subscribe(onNext: { [weak self] indexPath in
            viewModel.input.value = viewModel.input.value.play(asSource: indexPath.section)
        }).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.delegate = self
    }
    
}

