//
//  VKeyboard.swift
//  Logistics
//
//  Created by 李招利 on 2018/11/12.
//  Copyright © 2018 王岩. All rights reserved.
//

import UIKit

open class UIKeyboardView: UIView {
    
    
    public static func layout(by keyboard:UIKeyboard) -> UIKeyboardView {
        
        let view = UIKeyboardView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: keyboard.keyboardHeight))
        
        
        if #available(iOS 11.0, *) {
            let insets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
            view.frame.size.height += insets.bottom + 41
        }
        
        view.backgroundColor = UIColor.clear
        view.keyboard = keyboard
        
        return view
    }
    
    public override init(frame: CGRect) {
        isFromNib = false
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        isFromNib = true
        super.init(coder: aDecoder)
    }
    
    let isFromNib:Bool
//    @IBOutlet weak open var

    @IBOutlet weak open var collectionView:UICollectionView! {
        didSet {
            collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UIKeyboard.emptyCellIdentifier)
        }
    }
    @IBOutlet weak open var collectionHeight:NSLayoutConstraint! {
        didSet {
            collectionHeight?.constant = keyboard.keyboardHeight
        }
    }

    @IBOutlet private var _keyboard:UIKeyboard? {
        didSet { update(keyboard: _keyboard) }
    }
    open var keyboard:UIKeyboard {
        set {
//            update(keyboard: newValue)
            _keyboard = newValue
        }
        get {
            if let oldValue = _keyboard {
                return oldValue
            }
            let newValue = UIDefaultKeyboard()
//            update(keyboard: newValue)
            _keyboard = newValue
            return newValue
        }
    }
    
    public func layoutHeight() {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: keyboard.keyboardHeight)
        
        if #available(iOS 11.0, *) {
            let insets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
            frame.size.height += insets.bottom + 41
        }
    }
    
    private func update(keyboard newValue:UIKeyboard?) {
        collectionView?.collectionViewLayout = newValue ?? UIDefaultKeyboard()
        if #available(iOS 10.0, *) {
            collectionView?.prefetchDataSource = newValue
        }
        collectionView?.dataSource = newValue
        collectionView?.delegate = newValue
        collectionView?.contentInset = .zero
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }
        collectionHeight?.constant = newValue?.keyboardHeight ?? 216
        

//        _keyboard = newValue
    }
    
    @objc func responderChanged(_ newResponder:UIResponder?) {
        update(responder: newResponder)
    }
    
    private func update(responder:UIResponder?) {
        
        keyboard.responder = responder
        
        switch responder {
        case let input as UIResponder & UITextInput:
            keyboard.textInput = input
        default:  break
        }
        
        switch responder {
        case let custom as UICustomInput:
            keyboard.customResponder = custom
        default:  break
        }
    }
    
    open override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        
        print("change value for key:\(key)")
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard newSuperview != nil else {
            keyboard.textInput = nil
            return
        }
        
        let content = keyboard
        if !isFromNib, collectionView == nil {
            let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: content.keyboardHeight), collectionViewLayout: content)
            view.backgroundColor = UIColor.clear

            let heightLayout = view.anchor.height == content.keyboardHeight
            collectionHeight = heightLayout
            addSubview(view) {
                $0 += view.anchor.width     == $0.anchor.width
                $0 += view.anchor.leading   == $0.anchor.leading
                $0 += view.anchor.trailing  == $0.anchor.trailing
                $0 += view.anchor.top       == $0.safeArea.top && .levelHigh + 1
                $0 += view.anchor.bottom    <= $0.safeArea.bottom // && .levelHigh
                $0 += heightLayout
            }
            
            collectionView = view
        }
        
        update(keyboard: content)
        
//        let responder = UIApplication.shared.firstResponder()
        
        update(responder: UIApplication.firstResponderListener.value)
        
        UIApplication.firstResponderListener.removeNotice(target: self)
        UIApplication.firstResponderListener.addNotice(target: self, action: #selector(responderChanged(_:)))
    }
    
//    open override func didMoveToWindow() {
//        super.didMoveToWindow()
//        
//        if isFromNib {
//            for layout in self.constraints {
//                if layout.firstAttribute == .height, layout.firstItem === self {
//                    collectionHeight = layout
//                    collectionHeight.constant = 580
//                }
//            }
//        }
//        
//    }
}


public protocol UICustomInput: UIKeyInput {
        
    var rawValue:String { get set }
    
    var canDeleting:Bool { get }
    
    var inputTag:Int { get }
}
