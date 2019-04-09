//
//  UIKeyboardLayout.swift
//  Logistics
//
//  Created by 李招利 on 2018/11/12.
//  Copyright © 2018 王岩. All rights reserved.
//

import UIKit

open class UIKeyboard: UICollectionViewLayout {
    
    public static let emptyCellIdentifier = "Empty_Cell"
    
    private weak var inputDelegate:UITextInputDelegate?
    public weak var customResponder:UICustomInput? {
        didSet { initRawValue() }
    }
    public weak var responder:UIResponder? {
        didSet {
            guard registered !== collectionView, let collect = collectionView else {
                return
            }
            registered = collectionView
            collect.dataSource = self
            collect.delegate = self
            if #available(iOS 10.0, *) {
                collect.prefetchDataSource = self
            }
            registerCells()
        }
    }
    public weak var textInput:(UIResponder & UITextInput)? {
        didSet {
            oldValue?.inputDelegate = inputDelegate
            inputDelegate = textInput?.inputDelegate
            textInput?.inputDelegate = self
        }
    }
    private weak var registered:UICollectionView?
    
    open var keyboardHeight:CGFloat {
        return 216
    }
    
    /// need override
    open func registerCells() { }
    
    /// need override
    open func initRawValue() { }
}

extension UIKeyboard {
    
    
}

extension UIKeyboard: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

extension UIKeyboard: UICollectionViewDataSource {
    
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UIKeyboard.emptyCellIdentifier, for: indexPath)

        return cell
    }
    
}


extension UIKeyboard: UICollectionViewDataSourcePrefetching {
    
    @available(iOS 10.0, *)
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
    
    @available(iOS 10.0, *)
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }

}

extension UIKeyboard: UITextInputDelegate {
    
    open func selectionWillChange(_ textInput: UITextInput?) {
        inputDelegate?.selectionWillChange(textInput)
    }
    
    open func selectionDidChange(_ textInput: UITextInput?) {
        inputDelegate?.selectionDidChange(textInput)
    }
    
    open func textWillChange(_ textInput: UITextInput?) {
        inputDelegate?.textWillChange(textInput)
    }
    
    open func textDidChange(_ textInput: UITextInput?) {
        inputDelegate?.textDidChange(textInput)
    }
    
    
}

extension UITextInput {
    
    public func shouldChangeText(in textRange:UITextRange, replacement text:String) -> Bool {
        
        guard shouldChangeText?(in: textRange, replacementText: text) ?? true else {
            return false
        }
        var range = NSRange(location: 0, length: 0)
        range.location = offset(from: beginningOfDocument, to: textRange.start)
        let end = offset(from: beginningOfDocument, to: textRange.end)
        range.length = end - range.location

        switch self {
        case let textField as UITextField:
            return textField.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: text) ?? true
        case let textView as UITextView:
            return textView.delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        case let searchBar as UISearchBar:
            return searchBar.delegate?.searchBar?(searchBar, shouldChangeTextIn: range, replacementText: text) ?? true
        default:
            return true
        }
        
    }
    
}
