//
//  UICitizenIDKeyboard.swift
//  Logistics
//
//  Created by 李招利 on 2018/11/13.
//  Copyright © 2018 王岩. All rights reserved.
//

import Foundation

private let iButtonCell = "china.citizen.id.cell.button"
private let iNormalCell = "china.citizen.id.cell.normal"


open class UIChinaCitizenIDKeyboard: UIKeyboard {
    
    let keys = [        // ⌨︎⌘⇧✆⇪⚙︎⌨︎
        "1","2","3",
        "4","5","6",
        "7","8","9",
        "X","0","⌫"
    ]
    
    open override func registerCells() {
        guard let collection = collectionView else {
            return
        }
        if #available(iOS 11.0, *) {
            collection.layer.shadowOffset = CGSize(width: 0, height: 1)
            collection.layer.shadowColor  = UIColor.gray.cgColor
            collection.layer.shadowRadius = 0
            collection.layer.shadowOpacity = 1
        } else {
            collection.layer.shadowOffset = .zero
            collection.layer.shadowColor  = nil
            collection.layer.shadowRadius = 0
            collection.layer.shadowOpacity = 0
        }
        collection.register(UIKeyboardNormalCell.self, forCellWithReuseIdentifier: iNormalCell)
        collection.register(UIKeyboardButtonCell.self, forCellWithReuseIdentifier: iButtonCell)
    }
    
    private var attributes:[UICollectionViewLayoutAttributes] = []
    open override func prepare() {
        
        var inset = UIEdgeInsets.zero
        // 屏幕清晰度
        let scale = UIScreen.main.scale
        // 线条宽度
        var space = 1 / scale

        if #available(iOS 11.0, *) {
            space = 6
            inset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        }
        // 键位总高度
        let contentHeight = keyboardHeight - inset.top - inset.bottom
        // 屏幕总宽度
        let total = UIScreen.main.bounds.width - inset.left - inset.right
        // 一个按钮宽度
        let width = floor(scale * (total - space * 2) / 3) / scale
        // 一个按钮的高度
        let height = floor(scale * (contentHeight - space * 3) / 4) / scale
        
        attributes.removeAll(keepingCapacity: false)
        attributes.reserveCapacity(keys.count)
        
        for i in 0..<keys.count {
            let row = CGFloat(i / 3)
            let column = CGFloat(i % 3)
            let indexPath = IndexPath(row: i, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame.origin.x = inset.left + column * (width + space)
            attribute.frame.origin.y = inset.top + row * (height + space)
            attribute.frame.size.width = width
            attribute.frame.size.height = height
            
            attributes.append(attribute)
        }
        
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? keys.count : 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = indexPath.row < 11 ? iButtonCell : iNormalCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! UIKeyboardCell
        if indexPath.row < 11 {
            cell.textLabel.text = keys[indexPath.row]
        } else if indexPath.row == 11 {
            cell.textLabel.text = "⌫"
        } else {
            cell.textLabel.text = nil
        }
        cell.textLabel.font = UIFont.systemFont(ofSize: 24)
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let input = textInput,
            indexPath.section == 0,
            indexPath.row < keys.count else {
            return
        }
        var selectRange = input.selectedTextRange ?? input.textRange(from: input.endOfDocument, to: input.endOfDocument)!
        
        var text = ""
        if indexPath.row < 11 {
            // 其他输入
            text = keys[indexPath.row]
            
        } else if indexPath.row == 11, selectRange.isEmpty,
            let start = input.position(from: selectRange.end, offset: -1),
            let range = input.textRange(from: start, to: selectRange.end) {
            // 删除键
            selectRange = range
        } else if indexPath.row == 11, selectRange.isEmpty,
            input.textRange(from: input.beginningOfDocument, to: input.endOfDocument)?.isEmpty ?? false {
            // 无内容时删除无效
            return
        }
        
        if  input.shouldChangeText(in: selectRange, replacement: text) {
            input.replace(selectRange, withText: text)
        }
//        input.selectedTextRange = selectRange
//        input.insertText(text)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let buttonCell = cell as? UIKeyboardButtonCell else { return }
        
        buttonCell.textLabel.clipsToBounds = true
        if #available(iOS 11.0, *) {
            buttonCell.textLabel.layer.cornerRadius = 5
        } else {
            buttonCell.textLabel.layer.cornerRadius = 0
        }
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section == 0, indexPath.row < attributes.count {
            return attributes[indexPath.row]
        }
        return nil
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    
    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }

    
}
