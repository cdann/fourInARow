//
//  BoardCollectionViewController.swift
//  fourinrowexperience
//
//  Created by celine dann on 14/02/2019.
//  Copyright © 2019 celine dann. All rights reserved.
//

import UIKit

class BoardCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet weak var collectionview: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.delegate = self
        collectionview.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 1 ? 42 : 7
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = indexPath.section == 1 ? "emptyCell" : "redArrow"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
    
    // override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        //
        //        // Configure the cell
        //        cell.backgroundColor = UIColor(named: "blue grid")
        //
        //        return cell
        //    }
    
}
