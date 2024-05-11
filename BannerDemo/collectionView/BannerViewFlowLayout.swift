//
//  BannerViewFlowLayout.swift
//  BannerDemo

import UIKit

class BannerViewFlowLayout: UICollectionViewFlowLayout {
    public var isZoom:Bool = false
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let tmps = super.layoutAttributesForElements(in: rect)
        if !self.isZoom {
            return tmps
        }
        let centerX = (self.collectionView?.contentOffset.x ?? 0) + (self.collectionView?.bounds.size.width ?? 0) * 0.5
        if tmps == nil {
            return tmps
        }
        for attributes in tmps! {
            let centerDistance = abs(attributes.center.x - centerX)
            let scale = 1.0 / (1 + centerDistance * 0.001)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        return tmps
    }
}
