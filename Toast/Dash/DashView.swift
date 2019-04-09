//
//  DashView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/3/5.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

@objc public protocol ShapeDelegate:NSObjectProtocol {
    
    func shapePath(in rect:CGRect) -> CGPath
    
}


@IBDesignable
open class DashView: UIView {
    
    /* The color to fill the path, or nil for no fill. Defaults to opaque
     * black. Animatable. */
    @IBInspectable
    open var fillColor: UIColor? {
        didSet { _dashLayer?.fillColor = fillColor?.cgColor }
    }
    
    /* The color to fill the path's stroked outline, or nil for no stroking.
     * Defaults to nil. Animatable. */
    @IBInspectable
    open var strokeColor: UIColor? = UIColor.darkGray {
        didSet { _dashLayer?.strokeColor = strokeColor?.cgColor }
    }
    
    /* These values define the subregion of the path used to draw the
     * stroked outline. The values must be in the range [0,1] with zero
     * representing the start of the path and one the end. Values in
     * between zero and one are interpolated linearly along the path
     * length. strokeStart defaults to zero and strokeEnd to one. Both are
     * animatable. */
    @IBInspectable
    open var strokeStart: CGFloat = 0 {
        didSet {_dashLayer?.strokeStart = strokeStart }
    }
    
    @IBInspectable
    open var strokeEnd: CGFloat = 1 {
        didSet {_dashLayer?.strokeEnd = strokeEnd }
    }
    
    
    /* The line width used when stroking the path. Defaults to one.
     * Animatable. */
    @IBInspectable
    open var lineWidth: CGFloat = 1 {
        didSet {_dashLayer?.lineWidth = lineWidth }
    }
    
    
    /* The miter limit used when stroking the path. Defaults to ten.
     * Animatable. */
    @IBInspectable
    open var miterLimit: CGFloat = 10 {
        didSet {_dashLayer?.miterLimit = miterLimit }
    }
    
    
    /* The cap style used when stroking the path. Options are `butt', `round'
     * and `square'. Defaults to `butt'. */
    @IBInspectable
    open var lineCap: String = convertFromCAShapeLayerLineCap(CAShapeLayerLineCap.butt) {
        didSet {_dashLayer?.lineCap = convertToCAShapeLayerLineCap(lineCap) }
    }
    
    
    /* The join style used when stroking the path. Options are `miter', `round'
     * and `bevel'. Defaults to `miter'. */
    
    @IBInspectable
    open var lineJoin: String = convertFromCAShapeLayerLineJoin(CAShapeLayerLineJoin.miter) {
        didSet {_dashLayer?.lineJoin = convertToCAShapeLayerLineJoin(lineJoin) }
    }
    
    
    /* The phase of the dashing pattern applied when creating the stroke.
     * Defaults to zero. Animatable. */
    @IBInspectable
    open var lineDashPhase: CGFloat = 1 {
        didSet {_dashLayer?.lineDashPhase = lineDashPhase }
    }
    
    
    /* The dash pattern (an array of NSNumbers) applied when creating the
     * stroked version of the path. Defaults to nil. */
    @IBInspectable
    open var lineDashPattern: String? = "1,1,1,1" {
        didSet { updateLineDashPattern() }
    }
    
    private func updateLineDashPattern() {
        let values = (lineDashPattern ?? "").split(separator: ",").map { "\($0)" }
        guard let dash = _dashLayer,
            values.count > 1 else {
            return
        }
        dash.lineDashPattern = values.map {
            NSNumber(value: Double($0) ?? 1)
        }
    }

    
    @IBOutlet open weak var delegate:ShapeDelegate?

    private var _dashLayer:CAShapeLayer? = nil
    public var dashLayer:CAShapeLayer {
        guard let dash = _dashLayer else {
            let dash = CAShapeLayer()
            dash.path = delegate?.shapePath(in: bounds)
            dash.fillColor = fillColor?.cgColor
            dash.strokeColor = strokeColor?.cgColor
            dash.strokeStart = strokeStart
            dash.strokeEnd = strokeEnd
            dash.lineDashPhase = lineDashPhase
            dash.lineJoin = convertToCAShapeLayerLineJoin(lineJoin)
            dash.lineCap = convertToCAShapeLayerLineCap(lineCap)
            dash.lineWidth = lineWidth
            _dashLayer = dash
            updateLineDashPattern()
            
            layer.addSublayer(dash)
            return dash
        }
        return dash
    }
    
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        dashLayer.frame = bounds
        dashLayer.path  = delegate?.shapePath(in: bounds)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineCap(_ input: CAShapeLayerLineCap) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineJoin(_ input: CAShapeLayerLineJoin) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineJoin(_ input: String) -> CAShapeLayerLineJoin {
	return CAShapeLayerLineJoin(rawValue: input)
}
