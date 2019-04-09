//
//  ScrollContainer.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/27.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class ScrollContainer: UIScrollView {

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: self)
            return abs(translation.x) > abs(translation.y) * 0.75
        }
        return true
    }
    
//    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }

}
