//
//  CampaignFlowLayout.swift
//  CampaignBrowser
//
//  Created by Vignesh J on 20/07/21.
//  Copyright © 2021 Westwing GmbH. All rights reserved.
//

import UIKit

/// Reference: https://stackoverflow.com/a/51231881/618994
class CampaignFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?
            .map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
        
        layoutAttributesObjects?.forEach {
            if $0.representedElementCategory == .cell,
               let newFrame = self.layoutAttributesForItem(at: $0.indexPath)?.frame {
                $0.frame = newFrame
            }
        }
        return layoutAttributesObjects
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView ,
              let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        layoutAttributes.frame.origin.x = sectionInset.left
        layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width -
            sectionInset.left -
            sectionInset.right
        return layoutAttributes
    }
}
