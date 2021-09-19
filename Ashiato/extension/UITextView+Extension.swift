//
//  UITextViewExtention.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/13.
//

import UIKit

extension UITextView {
    //プロパティで行で計算できるようにしたら👍
    var textViewMaxHeight: CGFloat {
        get {
            return 66.5
        }
    }
    
    var isTwoCharFromTextEndSamePosition: Bool {
        get {
            if 2 <= text.count {
                let positionPrevEnd = layoutManager.location(forGlyphAt: text.count - 1)
                let positionEnd = layoutManager.location(forGlyphAt: text.count - 2)
                return positionPrevEnd == positionEnd
            }
            return false
        }
    }
    var isTextEndDoubleSpace: Bool {
        get {
            if 2 <= text.count {
                let charPrevEnd = text[text.index(text.endIndex, offsetBy: -2)]
                let charEnd = text[text.index(text.endIndex, offsetBy: -1)]
                return (charPrevEnd == " " || charPrevEnd == "　") && (charEnd == " " || charEnd == "　")
            }
            return false
        }
    }
    
    func fitTextToIntrinsicContentSize() {
        var isCharacterOutsideRange = textViewMaxHeight < intrinsicContentSize.height
        while isCharacterOutsideRange {
            text = String(text.dropLast())
            invalidateIntrinsicContentSize()
            isCharacterOutsideRange = textViewMaxHeight < intrinsicContentSize.height
        }
        
        constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = min(textViewMaxHeight,intrinsicContentSize.height)
            }
        }
        
    }
    
    func removeSpaceOutsideRange() {
        if isTextEndDoubleSpace && isTwoCharFromTextEndSamePosition{
            text = String(text.dropLast())
        }
    }
}
