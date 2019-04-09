//
//  DatesContainer.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/23.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class DatesContainer: LoopView {
    
    open var maskLayer:CAGradientLayer {
        if let mask = self.layer.mask as? CAGradientLayer { return mask }
        let mask = CAGradientLayer()
        mask.colors = [
            UIColor(white: 0, alpha: 0).cgColor,
            UIColor(white: 0, alpha: 1).cgColor,
            UIColor(white: 0, alpha: 1).cgColor,
            UIColor(white: 0, alpha: 0).cgColor
        ]
        mask.locations  = [0.0, 0.1, 0.9, 1.0]
        mask.startPoint = CGPoint(x: 0.5, y: 0)
        mask.endPoint   = CGPoint(x: 0.5, y: 1)
        self.layer.mask = mask
        return mask
    }
    

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview == nil { return }
        clipsToBounds = true
        isUserInteractionEnabled = true
        
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let s1 = NSNumber(value: Double(8 / bounds.height))
        let s2 = NSNumber(value: 1 - s1.doubleValue)
        maskLayer.locations = [0.0, s1, s2, 1.0]
        maskLayer.frame = bounds
    }
}


