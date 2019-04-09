//
//  CalendarBaseCell.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/23.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

@IBDesignable
open class CalendarBaseCell: CornerView {

    @IBInspectable open var textRatio:CGFloat = 0.7 {
        didSet { setNeedsLayout() }
    }
    
    private lazy var fontSize:CGFloat = {
        return ceil(UIScreen.main.bounds.width / 375 * 13)
    }()

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil { return }
        createUI()
    }
    
    private func createLabel(to label: inout UILabel?) -> UILabel {
        let textLabel:UILabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: fontSize)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.setContentHuggingPriority(.required, for: .vertical)
        textLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        label = textLabel
        return textLabel
    }
    
    private func createUI() {
        if _numberLabel != nil { return }
        
        let number = createLabel(to: &_numberLabel)
        let text   = createLabel(to: &_textLabel)
        
        number.font = UIFont.systemFont(ofSize: ceil(textRatio / 0.5 * fontSize))
        text.font   = UIFont.systemFont(ofSize: ceil((1 - textRatio) / 0.5 * fontSize))
        
        addSubviews([number, text]) {
            $0 += number.anchor.leading    == self.anchor.leading
            $0 += number.anchor.trailing   == self.anchor.trailing
            $0 += number.anchor.top        == self.anchor.top + 2.5
            $0 += number.anchor.bottom     == text.anchor.top + 5
            $0 += text.anchor.leading      == self.anchor.leading
            $0 += text.anchor.trailing     == self.anchor.trailing
            $0 += text.anchor.bottom       == self.anchor.bottom - 2.5
            $0 += number.anchor.height     == text.anchor.height * (textRatio / 0.5)
        }
    }
    
    weak var _numberLabel:UILabel?
    open var numberLabel:UILabel {
        createUI()
        return _numberLabel!
    }
    
    weak var _textLabel:UILabel?
    open var textLabel:UILabel {
        createUI()
        return _textLabel!
        
    }
    
    
}
