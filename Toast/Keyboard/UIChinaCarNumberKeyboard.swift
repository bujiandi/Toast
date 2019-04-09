//
//  UICarNoKeyboard.swift
//  Logistics
//
//  Created by 李招利 on 2018/11/13.
//  Copyright © 2018 王岩. All rights reserved.
//

import UIKit

private let iButtonCell = "china.citizen.id.cell.button"
private let iNormalCell = "china.citizen.id.cell.normal"

open class UIChinaCarNumberKeyboard: UIKeyboard {
    
    let keys = [
        "A","B","C","D","E","F",
        "G","H","J","K","L","M",
        "N","P","Q","R","S","T",
        "U","V","W","X","Y","Z",
        "0","1","2","3","4","5",
        "6","7","8","9"," ","⌫"
    ]
    let provinces = [
        "京","津","沪","渝","冀","豫",
        "鲁","晋","陕","皖","苏","浙",
        "鄂","湘","赣","闽","粤","桂",
        "琼","川","贵","云","辽","吉",
        "黑","蒙","甘","宁","青","新",
        "藏","港","奥","台","  ","⌫"
    ]
    
    open override var keyboardHeight: CGFloat {
        return 280
    }
    
    open override func registerCells() {
        guard let collection = collectionView else {
            return
        }
        if #available(iOS 11.0, *) {
            collection.layer.shadowOffset = CGSize(width: 0, height: 1)
            collection.layer.shadowColor  = UIColor.lightGray.cgColor
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
        let width = floor(scale * (total - space * 5) / 6) / scale
        // 一个按钮的高度
        let height = floor(scale * (contentHeight - space * 5) / 6) / scale
        
        attributes.removeAll(keepingCapacity: false)
        attributes.reserveCapacity(keys.count)
        
        for i in 0..<keys.count {
            let row = CGFloat(i / 6)
            let column = CGFloat(i % 6)
            let indexPath = IndexPath(row: i, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame.origin.x = inset.left + column * (width + space)
            attribute.frame.origin.y = inset.top + row * (height + space)
            attribute.frame.size.width = width
            attribute.frame.size.height = height
            
            attributes.append(attribute)
        }
        
    }
    
    private func refreshCells(by collectionView:UICollectionView) {
        
        guard let input = textInput else { return }
        
        let selectRange = input.selectedTextRange ?? input.textRange(from: input.endOfDocument, to: input.endOfDocument)!
        let start = input.offset(from: input.beginningOfDocument, to: selectRange.start)
        
        for path in collectionView.indexPathsForVisibleItems {
            guard path.row < 36,
                let cell = collectionView.cellForItem(at: path) as? UIKeyboardCell
                else { continue }
            refresh(cell: cell, at: path, inputStart: start)
        }
    }
    
    private func refresh(cell:UIKeyboardCell, at indexPath:IndexPath, inputStart start:Int) {
        let row = indexPath.row
        let key = start == 0 ? provinces[row] : keys[row]
        cell.textLabel.text = key
        cell.textLabel.isHighlighted = start == 1 && (24..<34).contains(row)
    }
    
    open override func selectionDidChange(_ textInput: UITextInput?) {
        guard let collection = collectionView else { return }
        refreshCells(by: collection)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? keys.count : 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = indexPath.row < 34 ? iButtonCell : iNormalCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! UIKeyboardCell
//        cell.textLabel.font = UIFont(name: "HiraKakuProN-W3", size: 20)
        cell.textLabel.font = UIFont.systemFont(ofSize: 20)
        
        guard let input = textInput,
            indexPath.section == 0,
            indexPath.row < keys.count else {
                cell.textLabel.text = nil
                cell.textLabel.isHighlighted = false
                refresh(cell: cell, at: indexPath, inputStart: 0)
                return cell
        }
        
        let selectRange = input.selectedTextRange ?? input.textRange(from: input.endOfDocument, to: input.endOfDocument)!
        let start = input.offset(from: input.beginningOfDocument, to: selectRange.start)
        refresh(cell: cell, at: indexPath, inputStart: start)
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let input = textInput,
            indexPath.section == 0,
            indexPath.row < keys.count else {
                return
        }
        var selectRange = input.selectedTextRange ?? input.textRange(from: input.endOfDocument, to: input.endOfDocument)!
        
        let start = input.offset(from: input.beginningOfDocument, to: selectRange.start)
        let row = indexPath.row

        // 车牌号第二位跳过数字
        if start == 1, (24..<34).contains(row) {
            return
        }
        
        let key = start == 0 ? provinces[row] : keys[row]
        
        var text = ""
        if indexPath.row < 34 {
            // 其他输入
            text = key
            // 如果第一位已经是省份, 则替换调selectRange
            if start == 0 { checkRangeText(&selectRange, input) }
            
        } else if indexPath.row == 35, selectRange.isEmpty,
            let start = input.position(from: selectRange.end, offset: -1),
            let range = input.textRange(from: start, to: selectRange.end) {
            // 删除键
            selectRange = range
        } else if indexPath.row == 35, selectRange.isEmpty,
            input.textRange(from: input.beginningOfDocument, to: input.endOfDocument)?.isEmpty ?? false {
            return
        }
        
        if  input.shouldChangeText(in: selectRange, replacement: text) {
            input.replace(selectRange, withText: text)
        }
//        input.selectedTextRange = selectRange
//        input.insertText(text)
        refreshCells(by: collectionView)
    }
    
    private func checkRangeText(_ selectRange: inout UITextRange, _ input:UITextInput) {
        if input.offset(from: input.beginningOfDocument, to: input.endOfDocument) <= 0 {
            return
        }
        let start = input.position(from: input.beginningOfDocument, offset: 0)!
        let end = input.position(from: input.beginningOfDocument, offset: 1)!
        
        guard let range = input.textRange(from: start, to: end),
            let text = input.text(in: range) else { return }
        
        if provinces[0..<34].contains(text),
            let range = input.textRange(from: start, to: selectRange.isEmpty ? end : selectRange.end) {
            selectRange = range
        }
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
