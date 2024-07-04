//
//  BannerView.swift
//  BannerDemo

import UIKit

@objc protocol BannerViewDelegate {
    func bannerView(_ bannerView:BannerView ,_ selectIndex:NSInteger)
   @objc optional func bannerViewScroll(_ bannerView:BannerView ,_ currentIndex:NSInteger)
}

enum BannerViewRollDirectionType:String {
    case rightToLeft = "rightToLeft"
    case leftToRight = "leftToRight"
}

class BannerView: UIView {
    
    public weak var delegate: BannerViewDelegate?
    
    public var imageDatas:[String]? {
        willSet {
            DispatchQueue.global().async {
                self.setupDatas()
            }
        }
    }
    
    public var infiniteLoop = true
    
    public var autoScroll = true {
        willSet {
            if newValue != autoScroll {
                invalidateTimer()
                if newValue {
                    setupTimer()
                }
            }
        }
    }
    
    public var isZoom = false {
        willSet {
            self.layout?.isZoom = newValue
        }
    }
    
    public var autoScrollTimeInterval:CGFloat = 2.0
    
    public var itemWidth:CGFloat = 0.0 {
        willSet {
            self.layout?.itemSize = CGSize(width: newValue, height: self.bounds.height)
        }
    }
    
    public var itemSpace:CGFloat = 0.0 {
        willSet {
            self.layout?.minimumLineSpacing = newValue
        }
    }
    
    public var rollType:BannerViewRollDirectionType = .rightToLeft
    
    public var imgCornerRadius:CGFloat = 0.0
    
    public var placeholderImage:UIImage?
    
    public var imageViewContentMode: UIView.ContentMode = .scaleToFill
    
    public var isClips = false
    
    public  var pageControl: PageControl?
    
    private var layout:BannerViewFlowLayout?
    private var collectionView:UICollectionView?
    private var nums  = 0
    private var dragIndex = 0
    private var lastX:CGFloat = 0.0
    private var timer:Timer?
    private var bannerDatas:[String] = Array()
    
    override init(frame: CGRect) {
       super.init(frame: frame)
        setupCollectioView()
        setupPageControlView()
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectioView()
        setupPageControlView()
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        superview?.willMove(toSuperview: newSuperview)
        invalidateTimer()
    }
}

extension BannerView {
    
    private func setupCollectioView() {
        let layout = BannerViewFlowLayout()
        layout.isZoom = self.isZoom
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: self.itemWidth, height: self.bounds.height)
        self.layout = layout
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.register(BannerViewCell.self, forCellWithReuseIdentifier: "kBannerViewCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = self.backgroundColor
        self.collectionView = collectionView
        self.addSubview(collectionView)
    }
    private func setupPageControlView() {
        let pageControl = PageControl(frame: CGRect(x: 0, y: self.bounds.height - 15, width: self.bounds.width, height: 15))
        pageControl.pageType = .sizeDot
        pageControl.normalColor = .lightGray
        pageControl.selectColor = .white
        pageControl.currentIndex = 0
        self.pageControl = pageControl
        self.addSubview(pageControl)
    }
}

extension BannerView {
    private func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: TimeInterval(self.autoScrollTimeInterval), target: self, selector: #selector(timerInvoke), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    @objc private func timerInvoke() {
        automaticScroll()
    }
    private func setupDatas() {
        if imageDatas == nil || imageDatas?.count == 0 {
            return
        }
        for imageStr in self.imageDatas! {
            self.bannerDatas.append(imageStr)
        }
        
        DispatchQueue.main.async {
            if  self.bannerDatas.count > 1 {
                self.nums = self.infiniteLoop ? self.imageDatas!.count * 10000 : self.imageDatas!.count
                self.pageControl?.isHidden = false
                self.collectionView?.isScrollEnabled = true
                if self.autoScroll {
                    self.setupTimer()
                }
                self.pageControl?.totalPages = self.imageDatas!.count
            }else {
                self.nums = 1
                self.pageControl?.isHidden = true
                self.collectionView?.isScrollEnabled = false
                self.invalidateTimer()
            }
            self.collectionView?.reloadData()
              
            self.scrollCollectionItemIndexCenter()
        }
        
        
    }
    private func currentIndex()  -> NSInteger{
        if self.collectionView?.frame.width == 0 ||
        self.collectionView?.frame.height == 0{
            return 0
        }
        var index:NSInteger = 0
        if self.layout?.scrollDirection == .horizontal {
            let allWidth = ((self.collectionView?.contentOffset.x ?? 0) + (self.itemWidth + self.itemSpace) * 0.5)
            index = NSInteger(allWidth / (self.itemWidth + self.itemSpace))
        }
       return max(0, index)
    }
    private func scrollCollectionItemIndexCenter() {
        self.collectionView?.frame = self.bounds
        self.layout?.itemSize = CGSize(width: self.itemWidth, height: self.bounds.height)
        self.layout?.minimumLineSpacing = self.itemSpace
        if self.collectionView?.contentOffset.x == 0 && self.nums > 0 {
            let targeIndex = self.infiniteLoop ? (self.nums / 2) : 0
            self.collectionView?.scrollToItem(at: IndexPath(row: targeIndex, section: 0), at: .centeredHorizontally, animated: false)
            self.lastX = self.collectionView?.contentOffset.x ?? 0.0
            self.collectionView?.isUserInteractionEnabled = true
        }
    }
    private func pauseScroll() {
        self.timer?.fireDate = NSDate.distantFuture
    }
    private func repauseScroll() {
        self.timer?.fireDate = NSDate.distantPast
    }
    private func automaticScroll() {
        if self.nums == 0 {
            return
        }
        var currentIndex = self.currentIndex()
        var targeIndex:NSInteger = 0
        if self.rollType == .rightToLeft {
            targeIndex = currentIndex  + 1
        }else {
            if currentIndex == 0  {
                currentIndex = self.nums
            }
            targeIndex = currentIndex - 1
        }
        scrollToIndex(targeIndex)
        
    }
    private func scrollToIndex(_ index:NSInteger) {
        let scrollIndex =  index % self.bannerDatas.count
        if ((self.delegate?.bannerViewScroll?(self, scrollIndex)) != nil) {
            self.delegate?.bannerViewScroll?(self, scrollIndex)
        }
        var targeIndex = index
        if targeIndex >= nums && self.infiniteLoop {
            targeIndex = self.nums / 2
            self.collectionView?.scrollToItem(at: IndexPath(row: targeIndex, section: 0), at: .centeredHorizontally, animated: false)
            return
        }
        self.collectionView?.scrollToItem(at: IndexPath(row: targeIndex, section: 0), at: .centeredHorizontally, animated: true)
        
    }
}


extension BannerView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView?.isUserInteractionEnabled = false
        if self.bannerDatas.count == 0 {
            return
        }
        self.pageControl?.currentIndex = self.currentIndex() % self.bannerDatas.count
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastX = scrollView.contentOffset.x
        if self.autoScroll {
            invalidateTimer()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.autoScroll {
            setupTimer()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScrollingAnimation(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.collectionView?.isUserInteractionEnabled = true
        if self.bannerDatas.count == 0 {
            return
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.collectionView?.isUserInteractionEnabled = false
        let currentX = scrollView.contentOffset.x
        let moveWidth = currentX - self.lastX
        let  page = moveWidth / (self.itemWidth * 0.5)
        if velocity.x > 0 || page > 0 {
            self.dragIndex = 1
        }else if velocity.x < 0 || page < 0 {
            self.dragIndex = -1
        }else {
             self.dragIndex = 0
        }
        let scrolleIndex = (self.lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemWidth + self.itemSpace)
        var scrollRow = Int(scrolleIndex) + self.dragIndex
        if scrollRow >= self.nums  || scrollRow < 0{
            scrollRow = 0
        }
        
        self.collectionView?.scrollToItem(at: IndexPath(row: scrollRow, section: 0), at: .centeredHorizontally, animated: true)
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
         let scrolleIndex = (self.lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemWidth + self.itemSpace)
        var scrollRow = Int(scrolleIndex) + self.dragIndex
        if scrollRow >= self.nums || scrollRow < 0 {
            scrollRow = 0
        }
        self.collectionView?.scrollToItem(at: IndexPath(row: scrollRow, section: 0), at: .centeredHorizontally, animated: true)
    }
    
}


extension BannerView:UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nums
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let itemIndex = indexPath.row % self.bannerDatas.count
        let infoModel = self.bannerDatas[itemIndex]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kBannerViewCell", for: indexPath) as! BannerViewCell
        cell.isClips = self.isClips
        cell.placeholderImage = self.placeholderImage
        cell.imgCornerRadius = self.imgCornerRadius
        cell.imageContentMode = self.imageViewContentMode
        cell.infoModel = infoModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = currentIndex() % self.bannerDatas.count
        if self.delegate != nil {
            self.delegate?.bannerView(self, index)
        }
    }
}

