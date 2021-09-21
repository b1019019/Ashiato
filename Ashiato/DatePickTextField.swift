//
//  DatePickTextField.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/15.
//

import UIKit
class DatePickTextField: UITextField {
    var datePicker: UIDatePicker = UIDatePicker()
    
    func setup(viewWidth: CGFloat,defaultDate: Date) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: viewWidth, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // ピッカー設定
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        
        // インプットビュー設定(キーボードをカスタム)
        inputView = datePicker
        inputAccessoryView = toolbar
        
        // デフォルト日付
        datePicker.date = defaultDate
    }
    
    @objc func done() {
        endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        text = "\(formatter.string(from: datePicker.date))"
    }
    
}
