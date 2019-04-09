//
//  DateCell.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/23.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

private let chineseDays = ["未知",
    "初一","初二","初三","初四","初五","初六","初七","初八","初九","初十",
    "十一","十二","十三","十四","十五","十六","十七","十八","十九","二十",
    "廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十"
]

open class DateCell: CalendarBaseCell {
    
    internal var isToday:Bool = false {
        didSet {
            if isToday == oldValue { return }
            backgroundColor = isToday ? #colorLiteral(red: 1, green: 0.9583333333, blue: 0.95, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cornerRadius = isSelected || isToday ? 7 : 0
        }
    }
    
    internal var isSelected:Bool = false {
        didSet {
            if isSelected == oldValue { return }
            borderWidth = isSelected ? 1 : 0
            cornerRadius = isSelected || isToday ? 7 : 0
        }
    }
    
    private var index:Int = 0
    private var isHighlight:Bool = true {
        didSet {
            if isHighlight == oldValue { return }
            if isHighlight {
                switch index {
                case  0: numberLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
                case  6: numberLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                default: numberLabel.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
                }
            } else {
                numberLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
            textLabel.textColor = numberLabel.textColor
        }
    }
    internal func set(highlight:Bool, by index:Int) {
        self.index = index
        self.isHighlight = highlight
    }
    
    open var time:TimeInterval = Date().timeIntervalSince1970 {
        didSet{ dateChanged() }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil { return }
        borderColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        isUserInteractionEnabled = false
        setNeedsUpdateText()
    }
    
    private func dateChanged() {

        let chinese = Calendar(identifier: .chinese)
        let current = Calendar.current
        
        let date = Date(timeIntervalSince1970: time)
        
        let chineseComp = chinese.dateComponents([.day], from: date)
        let englishComp = current.dateComponents([.day], from: date)
        super._numberLabel?.text  = "\(englishComp.day!)"
        super._textLabel?.text    = chineseDays[chineseComp.day!]
        needsUpdateText = false
    }
    
    private var needsUpdateText:Bool = false
    open func setNeedsUpdateText() {
        needsUpdateText = true
    }

    open override var numberLabel:UILabel {
        needsUpdateText = true
        return super.numberLabel
    }
    
    open override var textLabel:UILabel {
        needsUpdateText = true
        return super.textLabel
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if needsUpdateText { dateChanged() }
    }
}
