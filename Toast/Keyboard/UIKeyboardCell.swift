//
//  UIKeyboardCell.swift
//  Toast
//
//  Created by 李招利 on 2018/11/15.
//  Copyright © 2018 yFenFen. All rights reserved.
//

import UIKit

open class UIKeyboardCell: UICollectionViewCell {
    
    private weak var _textLabel:UILabel?
    @IBOutlet open var textLabel:UILabel! {
        set { _textLabel = newValue }
        get {
            if _textLabel == nil {
                makeTextLabel()
            }
            return _textLabel
        }
    }
    
    fileprivate func makeTextLabel() {
        
        let label = UILabel(frame: contentView.bounds)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.lineBreakMode = .byClipping
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.black
        label.highlightedTextColor = UIColor.lightGray
        label.layout(to: contentView, insets: .zero)
        textLabel = label
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil, textLabel == nil else { return }
        makeTextLabel()
    }
    
}

open class UIKeyboardButtonCell: UIKeyboardCell {
    
    
    override func makeTextLabel() {
        super.makeTextLabel()
        textLabel.backgroundColor = UIColor.white
    }
}

open class UIKeyboardNormalCell: UIKeyboardCell {
    
    override func makeTextLabel() {
        super.makeTextLabel()
        textLabel.backgroundColor = UIColor.clear
    }
    
}
