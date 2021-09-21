//
//  PlaceTextView.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/12.
//
import UIKit

class PlaceTextView: UITextView {
    var placeHolder: String = "" {
        willSet {
            self.placeHolderLabel.text = newValue
            self.placeHolderLabel.sizeToFit()
        }
        didSet {
            textDidChanged()
        }
    }
    
    //参照されるまで値が設定されない
    //なぜここで使用しているのか：PlaceTextViewが生成されないと、参照できない情報があるから
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = self.font
        label.textColor = .gray
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NSLayoutConstraint.activate([
            placeHolderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            placeHolderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 7),
            placeHolderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            placeHolderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5)
        ])
    }
    
    func textDidChanged() {
        let shouldHidden = self.placeHolder.isEmpty || !self.text.isEmpty
        self.placeHolderLabel.alpha = shouldHidden ? 0 : 1
    }
    
}
