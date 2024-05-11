//
//  BannerViewCell.swift
//  BannerDemo

import UIKit
import SDWebImage

class BannerViewCell: UICollectionViewCell {
    
    public var infoModel: String? {
        willSet {
            guard let dataInfo = newValue else {
                return
            }
            self.image.sd_setImage(with: URL(string: dataInfo))
        }
    }
    
    public var imageContentMode: UIView.ContentMode = .scaleToFill {
        willSet {
            self.image.contentMode = newValue
        }
    }
    
    public var imgCornerRadius:CGFloat = 0.0 {
        willSet {
            if newValue > 0.0 {
                let maskPath = UIBezierPath(roundedRect: (self.image.bounds), cornerRadius: newValue)
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.bounds
                maskLayer.path = maskPath.cgPath
                self.image.layer.mask = maskLayer
            }
        }
    }
    
    public var placeholderImage: UIImage?
    
    public var isClips = false {
        willSet {
             self.image.clipsToBounds = newValue
        }
    }
    
    private var image = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        self.contentView.addSubview(image)
        image.frame = contentView.bounds
        image.contentMode = contentMode
        image.clipsToBounds = isClips
    }
}
