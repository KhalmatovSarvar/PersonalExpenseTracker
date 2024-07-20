//
//  AddCategoryVC+ColorCollectionView.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 13/07/24.
//

import UIKit


extension AddCategoryViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == iconCollectionView {
            let side = (collectionView.frame.width - 30) / 4 // 4 items in a row with 10 spacing
            return CGSize(width: side, height: side)
        } else {
            return CGSize(width: 60, height: 60)
        }
    }
}
