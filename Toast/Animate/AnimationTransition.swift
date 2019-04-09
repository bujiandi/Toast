//
//  AnimationTransition.swift
//  Toast
//
//  Created by 小歪 on 2018/6/29.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import QuartzCore

internal class AnimationTransition<Value> : AnimationBasic<CATransition, Value> where Value : RawRepresentable, Value.RawValue == String {
    
    internal init(style:TransitionStyle) {
        let transition = CATransition()
        transition.type = convertToCATransitionType(style.rawValue)
        super.init(transition)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
	return CATransitionType(rawValue: input)
}
