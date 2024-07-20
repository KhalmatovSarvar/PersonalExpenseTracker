//
//  AddCategoryVC+IconCollectionView.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 13/07/24.
//

import Foundation
import UIKit


extension AddCategoryViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == iconCollectionView {
            return iconData.count
        } else {
            return colorData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == iconCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCollectionViewCell.reuseIdentifier, for: indexPath) as! IconCollectionViewCell
            let icon = iconData[indexPath.item]
            cell.configure(with: icon)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as! ColorCollectionViewCell
            let color = colorData[indexPath.item]
            cell.configure(with: color)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == iconCollectionView {
            // Handle icon collection view selection
            if let selectedIconCell = collectionView.cellForItem(at: indexPath) as? IconCollectionViewCell {
                selectedIconCell.isSelected = true
                
                // Update viewModel or handle selection logic for icon
                let selectedIcon = iconData[indexPath.item]
                viewModel.icon = selectedIcon  // Example: Update viewModel property
            }
        } else if collectionView == colorCollectionView {
            // Handle color collection view selection
            if let selectedColorCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                selectedColorCell.isSelected = true
                
                // Update viewModel or handle selection logic for color
                let selectedColor = colorData[indexPath.item]
                viewModel.color = selectedColor  // Example: Update viewModel property
            }
        }
    }
}

