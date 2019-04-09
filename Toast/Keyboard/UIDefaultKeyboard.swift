//
//  UIDefaultKeyboard.swift
//  Logistics
//
//  Created by 李招利 on 2018/11/13.
//  Copyright © 2018 王岩. All rights reserved.
//

import UIKit

open class UIDefaultKeyboard: UIKeyboard {
    
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let input = textInput else { return }
        let range = input.textRange(from: input.beginningOfDocument, to: input.endOfDocument)!
        input.replace(range, withText: "d")
        input.resignFirstResponder()
    }
    
}
