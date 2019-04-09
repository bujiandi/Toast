//
//  WeekBar.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/23.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class WeekBar: UIView {

    let weekNames:[(String,String)] = [
        ("日","SUN"),
        ("一","MON"),
        ("二","TUE"),
        ("三","WED"),
        ("四","THU"),
        ("五","FRI"),
        ("六","SAT"),
    ]
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        subviews.forEach { $0.removeFromSuperview() }
        if newSuperview == nil { return }
        isUserInteractionEnabled = false
        
        let minWidth = floor((UIScreen.main.bounds.width - 60) / 7)
        
        for (chinese, english) in weekNames {
            let cell = CalendarBaseCell()
            let index = subviews.count
            switch index {
            case  0: cell.numberLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            case  6: cell.numberLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            default: cell.numberLabel.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
            }
            cell.numberLabel.text = chinese
            cell.textLabel.text = english
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
            cell += cell.textLabel.anchor.width >= minWidth
        }
        self += subviews.last!.anchor.trailing == self.anchor.trailing
    }

//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        let side = floor(bounds.width / 7)
//        let y = (bounds.height - side) / 2
//        for (i, view) in subviews.enumerated() {
//            let x = CGFloat(i) * side
//            view.frame = CGRect(x: x, y: y, width: side, height: side * 0.7)
//        }
//    }
    
}
