//
//  ViewController.swift
//  BannerDemo

import UIKit

class ViewController: UIViewController {
    
    private var banner = BannerView()
    let images = ["https://img.ivsky.com/img/tupian/pre/201911/04/shumu_daoying.jpg",
                  "https://img.ivsky.com/img/tupian/t/201911/09/ciwei.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(banner)
        banner.delegate = self
        
        banner.frame = .init(x: 0, y: 100, width: view.bounds.width, height: 200)
        banner.pageControl?.pageType = .sizeDot
        banner.pageControl?.pointHeight = 8
        banner.pageControl?.selectColor = .clear
        banner.pageControl?.normalColor = .clear
        banner.imageViewContentMode = .scaleAspectFill
        banner.isZoom = true
        banner.imgCornerRadius = 10
        banner.itemWidth = view.bounds.size.width - 40
        banner.itemSpace = -30
        banner.imageDatas = images
    }
}

//MARK: BannerViewDelegate
extension ViewController: BannerViewDelegate {
    func bannerView(_ bannerView: BannerView, _ selectIndex: NSInteger) {
        print("selectIndex = \(selectIndex)")
    }
}



