//
//  YearBar.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/24.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

@IBDesignable
open class YearBar: UIView {
    
    private func createLabel(to label: inout UILabel!) -> UILabel {
        let textLabel:UILabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.adjustsFontSizeToFitWidth = true
        label = textLabel
        return textLabel
    }
    
    private func createButton(by image:UIImage, to btn: inout UIButton!) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        btn = button
        return button
    }

    private func createUI() {
        if _titleContainer != nil { return }
        let prev = createButton(by: #imageLiteral(resourceName: "btn_prev"), to: &_prevButton)
        let next = createButton(by: #imageLiteral(resourceName: "btn_next"), to: &_nextButton)
        
        addSubviews([prev, next]) {
            $0 += prev.anchor.top      == self.anchor.top
            $0 += prev.anchor.bottom   == self.anchor.bottom
            $0 += prev.anchor.left     == self.anchor.centerX * 0.03
            $0 += prev.anchor.width    == 44
            $0 += next.anchor.top      == self.anchor.top
            $0 += next.anchor.bottom   == self.anchor.bottom
            $0 += next.anchor.right    == self.anchor.centerX * 1.97
            $0 += next.anchor.width    == 44
        }
        
        let view = UIView()
        _titleContainer = view
        
        let year = createLabel(to: &_yearLabel)
        year.font = UIFont.systemFont(ofSize: 25)
        let month1 = createLabel(to: &_monthLabel1)
        let month2 = createLabel(to: &_monthLabel2)
        
//        year.text = "2017"
//        month1.text = "十月"
//        month2.text = "October"
        month2.font = UIFont.systemFont(ofSize: 9)
        month2.textColor = UIColor(white: 51/255, alpha: 0.5)
        month1.textColor = UIColor(white: 51/255, alpha: 0.6)
        year.textColor = UIColor(white: 51/255, alpha: 0.7)

        view.addSubviews([year, month1, month2]) {
            $0 += year.anchor.leading  == view.anchor.leading
            $0 += year.anchor.top      == view.anchor.top + 8
            $0 += year.anchor.bottom   == view.anchor.bottom - 8
            $0 += year.anchor.trailing == month1.anchor.leading - 5
            $0 += month2.anchor.baseline == year.anchor.baseline + 2
            $0 += month2.anchor.trailing == view.anchor.trailing
            $0 += month2.anchor.leading == year.anchor.trailing + 5
            $0 += month1.anchor.bottom == month2.anchor.top
            $0 += month1.anchor.trailing == view.anchor.trailing
        }
        
        addSubview(view) {
            $0 += view.anchor.centerX == self.anchor.centerX
            $0 += view.anchor.centerY == self.anchor.centerY
            $0 += view.anchor.left >= prev.anchor.right
            $0 += view.anchor.right <= next.anchor.left
        }
    }
    
    private weak var _yearLabel:UILabel!
    private weak var _monthLabel1:UILabel!
    private weak var _monthLabel2:UILabel!
    
    private weak var _prevButton:UIButton!
    private weak var _nextButton:UIButton!
    
    private weak var _titleContainer:UIView?
    
    open var yearLabel:UILabel {
        createUI()
        return _yearLabel
    }
    open var monthLabel1:UILabel {
        createUI()
        return _monthLabel1
    }
    open var monthLabel2:UILabel {
        createUI()
        return _monthLabel2
    }
    
    open var prevButton:UIButton {
        createUI()
        return _prevButton
    }
    open var nextButton:UIButton {
        createUI()
        return _nextButton
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil { return }
        createUI()
    }
    
    
    
}
