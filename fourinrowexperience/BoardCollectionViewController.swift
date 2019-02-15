//
//  BoardCollectionViewController.swift
//  fourinrowexperience
//
//  Created by celine dann on 14/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import UIKit

//class BoardCell: UICollectionViewCell {
//    @IBOutlet weak var indication : UILabel!
//}

class BoardCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionview : UICollectionView!
    var viewModel : BoardCollectionModelView? {
        didSet {
            if self.isViewLoaded {
                viewModel?.onChange = { self.collectionview.reloadData() }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.delegate = self
        collectionview.dataSource = self
        if let viewModel = self.viewModel {
            viewModel.onChange = { self.collectionview.reloadData() }
        }
        self.collectionview.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Board.numberOfLines + 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Board.numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = indexPath.row > 0 ? "emptyCell" : "redArrow"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if indexPath.row > 0, let cellSetup = self.viewModel?.output[indexPath.section][indexPath.row - 1] {
            cell.backgroundColor = cellSetup.color
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.playInCell(section: indexPath.section, index: indexPath.row)
    }
    
}
