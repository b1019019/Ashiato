//
//  UICollectionView+Extension.swift
//  TableView in CollectionView
//
//  Created by Hajime Ito on 2021/08/30.
//
import UIKit

extension UICollectionView {
    func scrollToCenter(inSection section: Int) {
        let center = centerIndex(inSection: section)
        let path  = IndexPath(row: center, section: section)
        scrollToItem(at: path, at: .centeredHorizontally, animated: false)
    }
    
    func centerIndex(inSection section: Int) -> Int {
        return numberOfItems(inSection: section) / 2
    }
}

