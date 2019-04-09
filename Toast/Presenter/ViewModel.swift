//
//  File.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/3/3.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

//
//open class ViewModel<View, Data>: NSObject where View : UIView {
//
//    open func update(view:View, by data:Data) {
//        assertionFailure("未实现数据更新方法")
//    }
//}

public protocol ViewModel {
    
    var valid:Bool { get }
    
    func update(data:Any)
    
    func update(view:AnyObject)
    
}

extension ViewModel {
    
    public var valid:Bool { return true }
    
}
