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
            let collectionViewWidth = iconCollectionView.bounds.width
                let itemsPerRow: CGFloat = 4
                let spacing: CGFloat = 10
                
                let totalSpacing = (itemsPerRow - 1) * spacing
                let itemWidth = (collectionViewWidth - totalSpacing) / itemsPerRow
                let itemHeight = itemWidth // Adjust if you want a different height
                
                return CGSize(width: itemWidth, height: itemHeight)
        } else {
            return CGSize(width: 60, height: 60)
        }
    }
}
