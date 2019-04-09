//
//  WeekCell.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/25.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class WeekCell: UIView {

    open var time:TimeInterval = Date().timeIntervalSince1970 {
        didSet{ dateChanged() }
    }
    
    open var cells:[DateCell] { return subviews.compactMap { $0 as? DateCell } }
    
    private func dateChanged() {
        for i in 0..<subviews.count {
            let cell = subviews[i] as! DateCell
            cell.time = time + Double(i) * 24 * 3600
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
//        removeConstraints(constraints)
//        subviews.forEach { $0.removeFromSuperview() }
        if newSuperview == nil { return }
        isUserInteractionEnabled = false
        
        for index in 0..<7 {
            let cell = DateCell()
            switch index {
            case  0: cell.numberLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            case  6: cell.numberLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            default: cell.numberLabel.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
            }
            cell.textLabel.textColor = cell.numberLabel.textColor
            
            let last = subviews.last
            addSubview(cell) {
                if let view = last {
                    $0 += cell.anchor.leading  == view.anchor.trailing
                    $0 += cell.anchor.width    == view.anchor.width
                } else {
                    $0 += cell.anchor.leading  == self.anchor.leading
                }
                $0 += cell.anchor.top      == self.anchor.top
                $0 += cell.anchor.bottom   == self.anchor.bottom
            }
            cell.time = time + Double(index) * 24 * 3600
        }
        self += subviews.last!.anchor.trailing == self.anchor.trailing
    }
    
}
