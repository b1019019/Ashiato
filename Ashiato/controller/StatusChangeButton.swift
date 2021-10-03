//
//  StatusChangeButton.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/17.
//

import UIKit

enum DisplayModeStatusChangeButton: Int {
    case doing = 0
    case complete = 1
    case cancel = 2
}

class StatusChangeButton: UIButton {
    var displayMode: DisplayModeStatusChangeButton?
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        
    }
    */
    func setup() {
        layer.cornerRadius = 15
        setTitleColor(UIColor.black, for: .normal)
        
        if displayMode == .doing {
            backgroundColor = UIColor.cyan
            tintColor = .black
            let image = UIImage(systemName: "arrow.right")!
            setImage(image, for: .normal)
        } else if displayMode == .complete {
            backgroundColor = UIColor.green
            let image = UIImage(systemName: "checkmark")!
            setImage(image, for: .normal)
        } else if displayMode == .cancel {
            backgroundColor = UIColor.red
            let image = UIImage(systemName: "xmark")!
            setImage(image, for: .normal)
        }
    }
    
    func statusChange() {
        if displayMode == .doing {
            displayMode = .complete
        } else if displayMode == .complete {
            displayMode = .cancel
        } else if displayMode == .cancel {
            displayMode = .doing
        }
        setup()
    }
    
}
