//
//  UISegmentBar.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/6/7.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

@IBDesignable
public class UISegmentBar: UIScrollView {
    
    @IBInspectable public var enabled:Bool = true
    @IBInspectable public var averageStyle:Bool = false
    public var index:Int = 0 {
        didSet{
            percent = -1
            if index == oldValue {
                return
            }
            keepWidth = keepWidth == 0 ? 70 : keepWidth
            
            let count : Int = labels.count
            UIView.animate(withDuration: 0.35) { [unowned self] in
                UIView.setAnimationCurve(.easeInOut)
                
                if oldValue < count {
                    self.labels[oldValue].isHighlighted = false
                    self.labels[oldValue].font = self.font
                    self.labels[self.index].isHighlighted = true
                    self.labels[self.index].font = self.selectedFont
                    let frame = self.labels[self.index].frame
                    
                    if (!self.bounds.insetBy(dx: self.keepWidth, dy: 0).contains(frame)) {
                        if (self.index > oldValue) {
                            let nextIndex = min((self.labels.count) - 1, self.index + 1);
                            self.scrollRectToVisible((self.labels[nextIndex].frame), animated: false)
                        } else if ((self.labels.count) > 0) {
                            let nextIndex = max(0, self.index - 1)
                            self.scrollRectToVisible((self.labels[nextIndex].frame), animated: false)
                        }
                    }
                }
                
            }
            
        }
        
        
    }
    @IBInspectable public var bottomLineWidth:CGFloat = 0
    @IBInspectable public var bottomLineHeight:CGFloat = 3
    @IBInspectable public var titleOffset:CGFloat = 0
    @IBInspectable public var tabInterval:CGFloat = 0
    
    @IBInspectable public var keepWidth:CGFloat = 0
    
    @IBInspectable public var lineOffset: CGFloat = 0
    
    //处理是否平分整个屏幕
    @IBInspectable public var averageViewWidth = false
    
    
    @IBInspectable public var color:UIColor?
    //选中时字体颜色
    @IBInspectable public var selectedColor: UIColor?
    
    public var titles:Array<String> = []{
        
        didSet{
            if labels.count != titles.count {
                resetLabels()
            }
            if index >= titles.count{
                index = 0
            }
            
            for i in 0..<titles.count {
                labels[i].text = titles[i]
            }
            setNeedsLayout()
            setNeedsDisplay()
        }
        
    }
    public lazy var action:Selector? = nil
    public weak var target:AnyObject? = nil
    
    public var font:UIFont = UIFont.systemFont(ofSize: 16) {
        didSet{ labels.filter{ !$0.isHighlighted }.forEach{ $0.font = font }}
    }
    public var selectedFont:UIFont = UIFont.systemFont(ofSize: 16) {
        didSet{ labels.filter{ $0.isHighlighted }.forEach{ $0.font = selectedFont }}
    }
    
    //私有属性
    fileprivate var labels = [UILabel]()
    fileprivate var bottomLine:UIView?
    fileprivate var tap:UITapGestureRecognizer?
    fileprivate var startIndex:Int = 0
    fileprivate var endIndex:Int = 0
    fileprivate var percent:CGFloat = 0
    
    
    
    
    public func fromIndexToIndex(startIndex:Int,endIndex:Int,epercent:CGFloat){
        
        if startIndex < 0 || startIndex >= labels.count {
            return
        }
        if endIndex < 0 || endIndex >= labels.count{
            return
        }
        if epercent < CGFloat(0) || epercent > CGFloat(1) {
            return
        }
        
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.percent = epercent
        //var array:ContiguousArray<Int> = []
        
        let sPercent : CGFloat = 1 - epercent
        let w1 = (labels[startIndex].frame.width) * sPercent
        let w2 = (labels[endIndex].frame.width) * epercent
        let cx = ((labels[endIndex].center.x) - (labels[startIndex].center.x)) * epercent + labels[startIndex].center.x
        
        var frame = bottomLine?.frame ?? .zero
        frame.size.width = ceil(w1 + w2)
        frame.origin.x = ceil(cx - frame.width / 2)
        var rect = frame
        if bottomLineWidth > 0 {
            rect.origin.x += (rect.width - bottomLineWidth) / 2
            rect.size.width = bottomLineWidth
        }
        bottomLine?.frame = rect
    }
    
    
}
//扩展私有方法
extension UISegmentBar {
    
    func resetLabels() {
        
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll(keepingCapacity: true)
        
        percent = -1
        //如果移动偏移超出一页数量最大，则恢复到0
        // labels = Array<UILabel>()
        
        for i in 0..<titles.count {
            let label = UILabel()
            label.font = i == index ? selectedFont : font
            label.textColor = i == index ? (selectedColor ?? tintColor) : (color ?? UIColor.gray)
            label.textColor = color ?? .gray
            label.highlightedTextColor = selectedColor ?? tintColor
            label.textAlignment = .center
            label.isHighlighted = i == index
            label.text = titles[i]
            self.addSubview(label)
            labels.append(label)
        }
        bottomLine?.backgroundColor = tintColor
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if averageStyle {
            averageLayoutSubviews()
        }else{
            normalLayoutSubviews()
        }
    }
    func averageLayoutSubviews() {
        let font:UIFont = self.font
        if titles.count == 0 {
            return
        }
        let height = frame.height - bottomLineHeight - lineOffset
        let itemWidth = frame.width / CGFloat(titles.count)
        
        for i in 0..<titles.count {
            let str = titles[i]
            
            let width = (str as NSString).boundingRect(with: CGSize.zero, options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil).size.width + self.tabInterval
            labels[i].frame = CGRect(x: ceil(itemWidth - width) / 2 + ceil(CGFloat(i) * itemWidth), y: titleOffset + bottomLineHeight, width: ceil(width), height: height - bottomLineHeight)
            
            labels[i].text = titles[i]
            
        }
        self.contentSize = CGSize(width: self.bounds.width, height: height + bottomLineHeight)
        if index < (labels.count){
            setBottomLineFrame(CGRect(x: averageViewWidth ? CGFloat(index) * (self.frame.width / CGFloat(labels.count)) : (labels[index].frame.minX), y: height, width: averageViewWidth ? (self.frame.width / CGFloat(labels.count)) : (labels[index].frame.size.width), height: bottomLineHeight))
            //             setBottomLineFrame(CGRect(x: (labels[index].frame.minX), y: height, width:  (labels[index].frame.size.width), height: bottomLineHeight))
        }
        
    }
    
    func setBottomLineFrame(_ frame:CGRect){
        if percent < CGFloat(0) || percent > CGFloat(1) || startIndex < 0  || startIndex >= labels.count || endIndex < 0 || endIndex >= labels.count  {
            var rect = frame
            if bottomLineWidth > 0 {
                rect.origin.x += (rect.width - bottomLineWidth) / 2
                rect.size.width = bottomLineWidth
            }
            bottomLine?.frame = rect
        }else{
            fromIndexToIndex(startIndex: startIndex, endIndex: endIndex, epercent: percent)
        }
        
    }
    
    func normalLayoutSubviews() {
        
        let font:UIFont = self.font
        let height = frame.height - bottomLineHeight - lineOffset
        var lastX = tabInterval / 2
        for i in 0..<titles.count {
            
            let str = titles[i]
            let width = (str as NSString).boundingRect(with: CGSize.zero, options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil).size.width + self.tabInterval
            
            labels[i].frame = CGRect(x: i == 0 ? 0 : lastX, y: titleOffset + bottomLineHeight, width: ceil(width), height: height - bottomLineHeight)
            labels[i].text = titles[i]
            
            lastX = i == 0 ? width : width + lastX;
            
            
        }
        self.contentSize = CGSize(width: lastX, height: height + bottomLineHeight)
        
        
        if index < labels.count {
            setBottomLineFrame(CGRect(x: (labels[index].frame.minX), y: height, width: labels[index].frame.size.width, height: bottomLineHeight))
        }
        
    }
}

extension UISegmentBar {
    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        bottomLine?.backgroundColor = tintColor
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        bottomLine?.removeFromSuperview()
        
        if newSuperview == nil {
            return
        }
        
        let size = self.bounds.size
        let view:UIView = UIView.init(frame: CGRect(x: 0, y: size.height - bottomLineHeight, width: size.height / 4, height: bottomLineHeight))
        view.backgroundColor = tintColor
        self.addSubview(view)
        bottomLine = view
        
        if self.tap != nil {
            return
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(UISegmentBar.onTapped(_:)))
        
        self.addGestureRecognizer(tap)
        tap.isEnabled = self.enabled
        self.tap = tap
        
    }
    
    @objc func onTapped(_ tap:UITapGestureRecognizer) {
        let x = tap.location(in: self).x
        let count = labels.count
        for i in 0..<count {
            if x < (labels[i].frame.minX) || (labels[i].frame.maxX) < x {
                continue
            }
            if index == i {
                return
            }
            index = i
            
            UIView.animate(withDuration: 0.25) { [unowned self] in
                UIView.setAnimationCurve(.easeInOut)
                UIView.setAnimationDuration(0.1)
                if self.index < (self.labels.count) {
                    var frame = self.bottomLine?.frame ?? .zero
                    frame.origin.x = self.averageViewWidth ? (CGFloat(self.index) * (self.frame.width / CGFloat(self.labels.count))) : (self.labels[self.index].frame.origin.x)
                    frame.size.width = self.averageViewWidth ? (self.frame.width / CGFloat(self.labels.count)) : (self.labels[self.index].frame.size.width)
                    self.setBottomLineFrame(frame)
                    
                }
                
            }
            if self.action != nil {
                _ = self.target?.perform(self.action, with: i)
            }
            
            break
            
        }
        
        
    }
    
    override public var tintColor: UIColor!{
        didSet{
            super.tintColor = tintColor
            if index < (labels.count) {
                labels[index].textColor = selectedColor ?? tintColor
            }
            bottomLine?.backgroundColor = tintColor
        }
        
        
    }
    
    
}
