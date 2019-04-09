//
//  AnimationsMaker.swift
//  CloudMarkingDEMO
//
//  Created by 慧趣小歪 on 2017/11/25.
//  Copyright © 2017年 慧趣小歪. All rights reserved.
//

import QuartzCore

internal class AnimationsMaker<Layer> : AnimationBasic<CAAnimationGroup, CGFloat> where Layer : CALayer {
    
    internal let layer:Layer
    
    internal init(layer:Layer) {
        self.layer = layer
        super.init(CAAnimationGroup())
    }
    
    internal var animations:[CAAnimation] = []
    internal func append(_ animation:CAAnimation) {
        animations.append(animation)
    }
    
    internal var _duration:CFTimeInterval?
    
    /* The basic duration of the object. Defaults to 0. */
    @discardableResult
    internal func duration(_ value:CFTimeInterval) -> Self {
        _duration = value
        return self
    }
}
