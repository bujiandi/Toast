//
//  TableContainer.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/27.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class TableContainer: UITableView {

    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: self)
            // 优先 纵向滑动 如果横向移动较大才忽略TableView
            return abs(translation.x) * 0.75 < abs(translation.y)
        }
        return true
    }

}
