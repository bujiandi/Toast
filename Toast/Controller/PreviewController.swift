//
//  PreviewController.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/9/27.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class PreviewController: UIViewController {
    
    public func onDismiss(dismiss: @escaping @convention(block) () -> Void) {
        hidedBlock = dismiss
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    open override var shouldAutorotate: Bool { return true }
    

    public weak var scrollView:UIScrollView!
    open var contentView:(UIView, CGSize)? {
        didSet {
            if isViewLoaded { loadContentView() }
        }
    }
    
    @discardableResult
    public func showByToast() -> ToastCustom {
        let toast = Toast.custom(controller: self)
            .layoutContainerOn { [unowned self] (root, toast) in
                
                let view = toast.container
                
                view.layoutMargins = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                view.backgroundColor = UIColor.clear
                (view as? CornerView)?.cornerRadius = 0
                self.view.backgroundColor = UIColor.clear
                UIView.animate(withDuration: Toast.setting.animDuration) { [weak self] in
                    UIView.setAnimationCurve(.easeInOut)
                    self?.view.backgroundColor = UIColor.black
                }
                
                root.addSubview(view) {[
                    view.anchor.leading    == root.anchor.leading,
                    view.anchor.trailing   == root.anchor.trailing,
                    view.anchor.top        == root.anchor.top,
                    view.anchor.bottom     == root.anchor.bottom
                ]}

            }
            
            .show()
        
        self.onDismiss {
            toast.hide()
        }
        
        return toast
    }
    
    public func onHide() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else if presentedViewController != nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private lazy var hidedBlock: @convention(block) () -> Void = onHide
    
    private weak var superview:UIView? = nil
    private var frame:CGRect = CGRect.zero
    private var transform:CGAffineTransform = .identity
    private var constraints:[NSLayoutConstraint] = []
    
    open func loadContentView() {
        guard let (view, size) = contentView else { return }
        
        if view.superview !== scrollView {
            frame = view.frame
            transform = view.transform
            superview = view.superview
            constraints = view.superview?.constraints.filter({ $0.firstItem === view || $0.secondItem === view }) ?? []
        }
        
        let screen = self.view.bounds.size//UIScreen.main.bounds.size
        let x = (screen.width - size.width) / 2
        let y = (screen.height - size.height) / 2

        var layouts:[NSLayoutConstraint] = []
        let origin = CGPoint.zero
        var offset = CGPoint.zero
        if x < 0, y < 0 {
            offset = CGPoint(x: x, y: y)
        } else if x < 0 {
            offset.y = y
            scrollView.maximumZoomScale = screen.height / size.height
            scrollView.minimumZoomScale = screen.width / size.width
            
            layouts = [view.anchor.centerY == scrollView.anchor.centerY, view.anchor.height == size.height]
        } else if y < 0 {
            offset.x = x
            scrollView.maximumZoomScale = screen.width / size.width
            scrollView.minimumZoomScale = screen.height / screen.height
            layouts = [view.anchor.centerX == scrollView.anchor.centerX, view.anchor.width == size.width]
        }

        lastZoomScale = scrollView.maximumZoomScale
        
        view.frame = CGRect(origin: origin, size: size)

        let imageView = UIImageView(frame: view.frame)
        imageView.contentMode = view.contentMode
        if let view = view as? UIImageView {
            imageView.image = view.image
            imageView.highlightedImage = view.highlightedImage
            imageView.isHighlighted = view.isHighlighted
        }
        
        var root = superview
        while root?.superview != nil {
            root = root?.superview
        }
        let point = superview?.convert(frame.origin, to: root) ?? CGPoint.zero
        
        scrollView.addSubview(view)
        
        scrollView.addConstraints([
            view.anchor.leading == scrollView.anchor.leading + point.x + frame.minX,
            view.anchor.top  == scrollView.anchor.top + point.y + frame.minY,
            view.anchor.width == frame.width,
            view.anchor.height == frame.height
            ])
        
        
        scrollView.layoutIfNeeded()
        
        layouts += [
            view.anchor.leading    == scrollView.anchor.leading   && .levelHigh,
            view.anchor.trailing   == scrollView.anchor.trailing  && .levelHigh,
            view.anchor.top        == scrollView.anchor.top       && .levelHigh,
            view.anchor.bottom     == scrollView.anchor.bottom    && .levelHigh
        ]
        
        scrollView.removeConstraints(by: view)
        scrollView.addConstraints(layouts)
        scrollView.contentOffset = offset//CGPoint(x: x, y: y)
        
        UIView.animate(withDuration: Toast.setting.animDuration) { [weak self] in
            UIView.setAnimationCurve(.easeInOut)
            self?.scrollView.layoutIfNeeded()
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self

        
        view.addSubview(scrollView) {[
            scrollView.anchor.leading == view.anchor.leading,
            scrollView.anchor.trailing == view.anchor.trailing,
            scrollView.anchor.top == view.anchor.top,
            scrollView.anchor.bottom == view.anchor.bottom
            ]}
        
        self.scrollView = scrollView
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTapped))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        singleTap.delaysTouchesEnded = true
        singleTap.delaysTouchesBegan = true
        scrollView.addGestureRecognizer(singleTap)
        
        loadContentView()
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func dismissPreview() {
        
        if let (view, _) = contentView {
            let constraints = self.constraints
            let superview = self.superview
            let transform = self.transform
            let frame = self.frame
            let scrollView:UIScrollView! = self.scrollView
            
            var root = superview
            while root?.superview != nil {
                root = root?.superview
            }
            let point = superview?.convert(frame.origin, to: root) ?? CGPoint.zero
            
            scrollView.removeConstraints(by: view)
            scrollView.addConstraints([
                view.anchor.leading == scrollView.anchor.leading + point.x + frame.minX,
                view.anchor.top  == scrollView.anchor.top + point.y + frame.minY,
                view.anchor.width == frame.width,
                view.anchor.height == frame.height
                ])
            UIView.animate(withDuration: 0.5, animations: {
                UIView.setAnimationCurve(.easeInOut)
                view.transform = transform
                view.frame = frame
                scrollView.backgroundColor = UIColor.clear
                scrollView.window?.backgroundColor = UIColor.clear
                scrollView.contentOffset = CGPoint.zero
                scrollView.layoutIfNeeded()
                var root = scrollView.superview
                root?.backgroundColor = UIColor.clear
                while root?.superview != nil {
                    root = root?.superview
                    root?.backgroundColor = UIColor.clear
                }
                
            }) { [weak self] (finish:Bool) in
                self?.hidedBlock()
                superview?.addSubview(view) { constraints }
            }
            
        }
    }
    
    private var timer:DispatchSourceTimer? = nil
    private func resetTimer() {
        timer?.cancel()
        timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer!.setEventHandler { [weak self] in self?.dismissPreview() }
        timer!.schedule(deadline: .now() + 0.35)
        timer!.resume()
    }
    
    var lastZoomScale:CGFloat = 1.5
    @objc open func onDoubleTapped() {
        timer?.cancel()
        timer = nil
        
        var zoomScale:CGFloat = 1
        if scrollView.zoomScale != zoomScale {
            lastZoomScale = scrollView.zoomScale
        } else {
            zoomScale = lastZoomScale
        }
        scrollView.setZoomScale(zoomScale, animated: true)
    }
    
    @objc open func onSingleTapped() {
        resetTimer()
    }
}

extension PreviewController : UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let (view, size) = contentView else { return }
        for layout in scrollView.constraints where layout.firstItem === view {
            switch layout.firstAttribute {
            case .centerX:
                let imageScale = self.view.bounds.width / size.width
                layout.constant = (1 - min(imageScale, scale)) * size.width * 0.5
            case .centerY:
                let imageScale = self.view.bounds.height / size.height
                layout.constant = (1 - min(imageScale, scale)) * size.height * 0.5
            default: continue
            }
        }
        UIView.animate(withDuration: 0.3) {
            scrollView.layoutIfNeeded()
        }
    }
}
