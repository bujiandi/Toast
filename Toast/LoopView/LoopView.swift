//
//  LoopView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/25.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

//@inline(__always)
//private func hem(_ lhs:CGFloat) -> CGFloat {
//    return lhs < 0 ? floor(lhs) : ceil(lhs)
//}

//class ScrollView : UIScrollView {
//    override func removeFromSuperview() {
//        print("remove")
//    }
//}

open class LoopView: UIView {
    
    private func createUI() {
        if _scrollView != nil { return }
        
        let scroll = UIScrollView(frame: bounds)
        scroll.bounces = true
        scroll.alwaysBounceVertical = true
        scroll.alwaysBounceHorizontal = false
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.contentSize = CGSize(width: bounds.width, height: bounds.height * 3)
        scroll.contentOffset.y = bounds.height
        scroll.layout(toMargin: self, insets: UIEdgeInsets.zero)
        scroll.delegate = self
        _scrollView = scroll
    }
    
    open var visiableCells:[(index:Int, cell:UIView)] { return _cells }
    private var _cells:[(index:Int,cell:UIView)] = []
    
    private func loadData() {
        guard let delegate = delegate else { return }
        let scroll = scrollView

        // 取上临界的 cell index
        var cells:[(index:Int,cell:UIView)] = []

        var index:Int = Int(floor(offsetY / (cellHeight + cellInterval)))
        
        var y = CGFloat( Int(offsetY) % Int(cellHeight + cellInterval) )
        skipDidScroll = true
        scroll.contentOffset.y = cellHeight + cellInterval + y
        
        var last = delegate.loopViewCreateCell(self) //.loopView(self, cellForRow: index)
        cells.append((index, last))
        
        scroll.addSubview(last) {
            $0 += last.anchor.top == scroll.anchor.top + cellInterval
            $0 += last.anchor.width == scroll.anchor.width
            $0 += last.anchor.centerX == scroll.anchor.centerX
            $0 += last.anchor.height == cellHeight
        }
        
        y += cellHeight + cellInterval
        
        let max = bounds.height + (cellHeight + cellInterval) * 1
        while y < max {
            index += 1
            let cell = delegate.loopViewCreateCell(self)
            cells.append((index, cell))
            
            scroll.addSubview(cell) {
                $0 += cell.anchor.top == last.anchor.bottom + cellInterval
                $0 += cell.anchor.width == scroll.anchor.width
                $0 += cell.anchor.centerX == scroll.anchor.centerX
                $0 += cell.anchor.height == cellHeight
            }
            
            last = cell
            y += cellHeight + cellInterval
        }
        
        scroll += last.anchor.bottom == scroll.anchor.bottom - cellInterval
        _cells = cells
        for (index, cell) in cells {
            delegate.loopViewUpdate(self, cell: cell, forRow: index)
        }
    }
    
    open func reloadData() {
        removeConstraints(constraints)
        _scrollView?.removeConstraints(_scrollView!.constraints)
        _scrollView?.removeFromSuperview()
        _scrollView = nil
        createUI()
//       _cells.forEach { self.scrollView.remove(view: $0.cell) }  // $0.cell.removeFromSuperview() }
        loadData()
    }
    
    open var offsetY:CGFloat = 0
    open var cellHeight:CGFloat = 50
    open var cellInterval:CGFloat = 0
    
    private weak var _scrollView:UIScrollView?
    open var scrollView:UIScrollView {
        createUI()
        return _scrollView!
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil { return }
        scrollView.delegate = self
    }
    
    open weak var delegate:LoopViewDelegate?
    private var skipDidScroll:Bool = false
}

extension LoopView : UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if skipDidScroll {
            skipDidScroll = false
            delegate?.scrollViewDidScroll?(scrollView)
            return
        }
        
        let minY = scrollView.contentOffset.y
        let maxY = minY + scrollView.bounds.height
        
        let height = cellHeight + cellInterval
        
        if let (index, last) = _cells.last,
            scrollView.contentSize.height - maxY < height {
            let (_, cell) = _cells.removeFirst()
            scrollView.removeConstraints(by: cell)
            
            scrollView.removeConstraints(by: last, layout: .bottom)

            scrollView.addSubview(cell) {
                $0 += cell.anchor.top == last.anchor.bottom + cellInterval
                $0 += cell.anchor.width == scrollView.anchor.width
                $0 += cell.anchor.centerX == scrollView.anchor.centerX
                $0 += cell.anchor.height == cellHeight
                $0 += cell.anchor.bottom == scrollView.anchor.bottom - cellInterval
            }
            _cells.append((index + 1, cell))
            delegate?.loopViewUpdate(self, cell: cell, forRow: index + 1)

            if let top = _cells.first?.cell {
                scrollView += top.anchor.top == scrollView.anchor.top + cellInterval
            }
            skipDidScroll = true
            scrollView.contentOffset.y -= height
            return
        } else if let (index, first) = _cells.first, minY < height {
            let (_, cell) = _cells.removeLast() //scrollView.subviews.last as! UIView
            scrollView.removeConstraints(by: cell)

            scrollView.removeConstraints(by: first, layout: .top)
            scrollView.addSubview(cell) {
                $0 += cell.anchor.top == scrollView.anchor.top + cellInterval
                $0 += cell.anchor.width == scrollView.anchor.width
                $0 += cell.anchor.centerX == scrollView.anchor.centerX
                $0 += cell.anchor.height == cellHeight
                $0 += first.anchor.top == cell.anchor.bottom + cellInterval
            }
            _cells.insert((index - 1, cell), at: 0)
            delegate?.loopViewUpdate(self, cell: cell, forRow: index - 1)

            if let bottom = _cells.last?.cell {
                scrollView += bottom.anchor.bottom == scrollView.anchor.bottom - cellInterval
            }
            skipDidScroll = true
            scrollView.contentOffset.y += height
            return
        }
        
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool  {
        return delegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}


public protocol LoopViewDelegate : UIScrollViewDelegate {
    
    func loopViewCreateCell(_ loopView:LoopView) -> UIView
    
    func loopViewUpdate(_ loopView:LoopView, cell:UIView, forRow row:Int)

}
