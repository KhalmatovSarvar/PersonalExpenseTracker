//
//  AddTransactionViewController+CollectionView.swift
//  PersonalExpenseTracker
//
//  Created by Sarvar on 08/07/24.
//

import UIKit

extension AddTransactionViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("itemCount in collectionView: \(viewModel.categories.count + 1)")
        return viewModel.categories.count + 1 // +1 for the "Add Category" button
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
        
        if indexPath.item < viewModel.categories.count {
            cell.configure(with: viewModel.categories[indexPath.item])
        } else {
            cell.configureForAddCategory()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.categories.count {
            navigationController?.pushViewController(AddCategoryViewController(), animated: true)
            print("Add Category button tapped")
        } else {
            // Handle category selection
            print("Selected category: \(viewModel.categories[indexPath.item].title)")
            let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
            cell.contentView.backgroundColor = viewModel.categories[indexPath.item].color
            viewModel.category = viewModel.categories[indexPath.item]
        }
    }
    
    
    /*
     let cellWidth = (collectionViewWidth — (right inset + left inset + sum of all inter items paces) / (number of items that we want in each row )
     */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // get the Collection View width and height
        let collectionViewWidth = categoryCollectionView.frame.width
        print("collectionViewWidth:  \(collectionViewWidth)")
        // calculate Cell width and height
        let cellWidth = (collectionViewWidth - 24 ) / 4
        let cellHeight = cellWidth * 1.3
        
        print("width:  \(cellWidth)")
        print("height:  \(cellHeight)")
        
        
        return CGSize(width: cellWidth , height: cellHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        cell.contentView.backgroundColor = .clear
    }
    
    func updateCollectionViewHeight() {
           let numberOfItems = viewModel.categories.count + 1
           let itemsPerRow: CGFloat = 4
           let itemWidth = (categoryCollectionView.frame.width - 4 * 8) / itemsPerRow
           let itemHeight = itemWidth * 1.3
           let numberOfRows = ceil(CGFloat(numberOfItems) / itemsPerRow)
           let totalHeight = (numberOfRows * itemHeight) + ((numberOfRows - 1) * 8) + 8 * 2 // 8 for top and bottom insets
           
           // Update height constraint of collection view
           categoryCollectionView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
       }
    
    
    
}
extension UICollectionView {
    override open var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
}
