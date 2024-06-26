//
//  PageControl.swift
//  Company

import UIKit

enum PageControlStyle:Int {
    case rectangle
    case circle
    case hollow
    case square
    case sizeDot
}
enum PageControlDirection:Int {
    case leftDirection
    case rightDirection
    case centerDirection
}

class LoopPageView: UIView {
    
   public var selectColor:UIColor = .white
   
    public var normalColor:UIColor = .lightGray
    
    public var directionType:PageControlDirection = .centerDirection
    
    public var pageMargin:CGFloat  = 5
    
    public var height:CGFloat  = 5
    
    public var selectWidth:CGFloat  = 15
    
    private var temps:Array = Array<UIView>()
    
    private var backView:UIView = UIView()
    
    private var normalWidth:CGFloat  = 5
    
     public var pages:Int = 0{
         didSet {
            setupAllPages(oldValue)
        }
     }
    
     public var currentPage:Int = 0{
         didSet {
           setupCurrentPage(oldValue)
         }
     }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        self.backView  = UIView(frame: frame)
        self.addSubview(self.backView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupAllPages(_ oldValue:Int) {
        if self.pages == 0 {
            return
        }
         if oldValue == self.pages {
             return
         }
         self.backView.subviews.forEach { (view) in
             view.removeFromSuperview()
         }
         self.temps.removeAll()
        if self.height > self.frame.height {
            self.height = self.frame.height
        }
        self.normalWidth =  self.height
         let width = self.selectWidth + CGFloat((self.pages - 1)) * self.normalWidth + CGFloat(self.pages - 1) * self.pageMargin
         var frameX = (self.frame.maxX - width) * 0.5
        switch directionType {
           case .leftDirection:
               frameX = self.frame.minX + 20
               break
           case .rightDirection:
               frameX = self.frame.maxX - width - 20
               break
           default:
               frameX = (self.frame.maxX - width) * 0.5
         }
        
        self.backView.frame = CGRect(x: frameX, y: (self.frame.maxY -  self.height) * 0.5, width: width, height: self.height)
         var x:CGFloat = 0
         for i in 0 ..< self.pages {
             let view = UIView()
             if i == self.currentPage {
                 view.frame = CGRect(x: x, y: 0, width: self.selectWidth, height: height)
                 view.backgroundColor = self.selectColor
                 x += self.selectWidth + self.pageMargin
             }else {
                view.frame = CGRect(x: x, y: 0, width: self.normalWidth, height: height)
                 view.backgroundColor = self.normalColor
                 x += self.normalWidth + self.pageMargin
             }
             view.layer.cornerRadius = self.height * 0.5
             view.layer.masksToBounds = true
             self.backView.addSubview(view)
             self.temps.append(view)
         }
    }
    private func setupCurrentPage(_ oldValue:Int) {
        if oldValue != self.currentPage {
            self.currentPage = min(self.currentPage, self.pages - 1)
            var viewX:CGFloat = 0
            for i in 0 ..< self.pages {
                let view:UIView = self.temps[i]
                if i == self.currentPage {
                    view.frame = CGRect(x: viewX, y: 0, width: self.selectWidth, height: self.height)
                    viewX += self.selectWidth + self.pageMargin
                    view.backgroundColor = self.selectColor
                    continue
                }
                view.frame = CGRect(x: viewX, y: 0, width: self.normalWidth, height: self.height)
                viewX += self.normalWidth + self.pageMargin
                view.backgroundColor = self.normalColor
            }
        }
    }
    
}


class PageControl: UIPageControl {

    public var selectColor:UIColor = .white
    
    public var normalColor:UIColor = .lightGray
    
    public var pageType:PageControlStyle = .rectangle
    
    public var directionType:PageControlDirection = .centerDirection
    
    public var pageMargin:CGFloat  = 5
    
    public var pointHeight:CGFloat  = 5
    
    public var selectWidth:CGFloat  = 15
    
    public var totalPages:Int = 0 {
        didSet {
            setupTotolPages()
        }
    }
    
    public var currentIndex:Int = 0 {
        didSet {
            setupCurrentIndex(oldValue: oldValue)
        }
    }
    
    lazy private var loopPageView:LoopPageView = { () -> LoopPageView in
        let tmpView = LoopPageView(frame: self.bounds)
        tmpView.normalColor = self.normalColor
        tmpView.selectColor = self.selectColor
        tmpView.directionType = self.directionType
        tmpView.pageMargin = self.pageMargin
        tmpView.height = self.pointHeight
        tmpView.selectWidth = self.selectWidth
        return tmpView
    }()
    
   lazy private var pageView:UIView = { () -> UIView in
       let tmpView = UIView(frame: self.bounds)
       return tmpView
   }()
    private func setupTotolPages() {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        if self.totalPages == 0 {
            return
        }
        if self.pageMargin < 5.0 {
            self.pageMargin = 5.0
        }
        if self.pageType == .sizeDot {
            self.addSubview(self.loopPageView)
            self.loopPageView.normalColor = self.normalColor
            self.loopPageView.selectColor = self.selectColor
            self.loopPageView.directionType = self.directionType
            self.loopPageView.pageMargin = self.pageMargin
            self.loopPageView.height = self.pointHeight
            self.loopPageView.selectWidth = self.selectWidth
            self.loopPageView.pages = self.totalPages
            return
        }
        self.addSubview(self.pageView)
        let margin = self.pageMargin
        if self.pointHeight > self.bounds.height {
           self.pointHeight = self.bounds.height
        }
        let pointWidth = self.pointHeight
        var itemWidth = pointWidth
        var itemHeight = pointWidth
        for i in 0 ..< self.totalPages {
            var aview = UIView()
            aview.backgroundColor = (i == self.currentIndex) ? self.selectColor : self.normalColor
            switch self.pageType {
            case .circle:
                aview.frame = CGRect(x: (CGFloat(margin) + itemWidth) * CGFloat(i), y: 0, width: itemWidth, height: itemWidth)
                aview.layer.cornerRadius = pointWidth  * 0.5
                aview.clipsToBounds = true
                break
            case .square:
                itemWidth = pointWidth * 0.8
                itemHeight = itemWidth
                aview.frame = CGRect(x: (CGFloat(margin) + itemWidth) * CGFloat(i), y: 0, width: itemWidth, height: itemWidth)
                break
            case .hollow:
                let  frame = CGRect(x: (CGFloat(margin) + itemWidth) * CGFloat(i), y: 0, width: itemWidth, height: itemWidth)
                aview = CyclesView(frame: frame)
                let cycleView = aview as!  CyclesView
                cycleView.backgroundColor = .clear
                cycleView.borderWith = itemWidth * 0.2
                cycleView.fullColor = (i == self.currentIndex) ? self.selectColor : self.normalColor
                break
            default:
                itemWidth = pointWidth * 1.5
                itemHeight = pointWidth / 4.0
                aview.frame = CGRect(x: (CGFloat(margin) + itemWidth) * CGFloat(i), y: 0, width: itemWidth, height: itemHeight)
            }
            self.pageView.addSubview(aview)
        }
        let frameWidth = itemWidth * CGFloat(self.totalPages) + CGFloat(CGFloat(self.totalPages - 1) * margin)
        if self.bounds.maxX == 0 {
            self.frame = CGRect(x: 0, y: self.frame.minY, width: UIScreen.main.bounds.width, height: self.frame.height)
        }
        var frameX = self.bounds.maxX - frameWidth - 20
        switch directionType {
        case .leftDirection:
            frameX = self.bounds.minX + 20
            break
        case .rightDirection:
            frameX = self.bounds.maxX - frameWidth - 20
            break
        default:
            frameX = (self.bounds.maxX - frameWidth) * 0.5
        }
        self.pageView.frame = CGRect(x:frameX , y: (self.bounds.maxY - itemHeight) * 0.5, width: frameWidth , height: itemHeight)
    }
 
    private func setupCurrentIndex(oldValue:Int) {
        if self.pageType == .sizeDot {
            self.addSubview(self.loopPageView)
            self.loopPageView.normalColor = self.normalColor
            self.loopPageView.selectColor = self.selectColor
            self.loopPageView.directionType = self.directionType
            self.loopPageView.pageMargin = self.pageMargin
            self.loopPageView.height = self.pointHeight
            self.loopPageView.selectWidth = self.selectWidth
            self.loopPageView.currentPage = self.currentIndex
            return
        }
        self.addSubview(self.pageView)
        if oldValue != self.currentIndex {
            self.currentIndex  = min(self.currentIndex, self.totalPages - 1)
            for (index ,view) in self.pageView.subviews.enumerated() {
                if self.pageType == .hollow {
                   let cycleView = view as!  CyclesView
                   cycleView.fullColor = self.normalColor
                   if index == self.currentIndex {
                       cycleView.fullColor = self.selectColor
                    }
                    cycleView.setNeedsDisplay()
                    continue
                }
                view.backgroundColor = self.normalColor
                if index == self.currentIndex {
                   view.backgroundColor = self.selectColor
                }
            }
        }
    }
}
