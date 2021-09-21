//
//  TaskCreateModalViewController.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/17.
//

import UIKit

enum DisplayModeTaskCreateModal {
    case common
    case nextTask
    case branchTask
}

class TaskCreateModalViewController: UIViewController {
    @IBOutlet weak var textViewDescribeNecessity: PlaceTextView!
    @IBOutlet weak var textViewDescribeAchievementStandard: PlaceTextView!
    @IBOutlet weak var textViewDescribeMemo: PlaceTextView!
    
    @IBOutlet weak var textFieldShowTaskName: UITextField!
    @IBOutlet weak var textFieldEditStartDate: DatePickTextField!
    @IBOutlet weak var textFieldEditGoalDate: DatePickTextField!
    
    
    
    var displayMode:DisplayModeTaskCreateModal = .common
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewDescribeNecessity.delegate = self
        textViewDescribeAchievementStandard.delegate = self
        textViewDescribeMemo.delegate = self
        textFieldShowTaskName.delegate = self
        
        textFieldEditStartDate.setup(viewWidth: view.frame.width, defaultDate: Date())
        textFieldEditGoalDate.setup(viewWidth: view.frame.width, defaultDate: Date())
        
        textViewDescribeNecessity.placeHolder = "なぜこのタスクが必要か書こう！"
        textViewDescribeAchievementStandard.placeHolder = "何をもって完了とするのか書こう！"
        textViewDescribeMemo.placeHolder = "タスクに関するメモを書こう！"
        
        textViewDidChange(textViewDescribeNecessity)
        textViewDidChange(textViewDescribeAchievementStandard)
        textViewDidChange(textViewDescribeMemo)
        
        if displayMode == .nextTask {
            //延長元タスク名をタスク名表示テキストフィールドの上のラベルに書き込み
        } else if displayMode == .branchTask {
            //分岐元タスク名をタスク名表示テキストフィールドの上のラベルに書き込み
        }
        
        
        
        //キーボード出現、消滅の通知を受け取る
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(sender:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(sender:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc
    private func keyboardWillShow(sender: NSNotification) {
        //setumeiTextViewがFirstResponderである場合(setumeiTextViewがイベント処理中(編集中)である場合)
        [textViewDescribeNecessity,textViewDescribeAchievementStandard,textViewDescribeMemo].forEach {
            guard let textView = $0 else { return }
            if textView.isFirstResponder {
                //sender.userInfoは通知を送る際に追加で送られるデータ
                guard let userInfo = sender.userInfo else { return }
                //durationは間隔という意味
                //keyboardAnimationDurationUserInfoKeyはキーボードの表示アニメーションにかかる時間
                let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
                //キーボードのサイズを取得
                guard let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                
                //CGAffineTransformによるビューの縦移動
                UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                    
                    let textViewMinY = self.view.convert(textView.frame, from: textView.superview).minY
                    let destinationY = (self.view.frame.height - keyboardRect.height) / 2
                    let transform = CGAffineTransform(translationX: 0, y: destinationY - textViewMinY)
                    self.view.transform = transform
                    
                })
            }
        }
    }
    
    @objc
    private func keyboardWillHide(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        textViewDescribeNecessity.fitTextToIntrinsicContentSize()
        textViewDescribeAchievementStandard.fitTextToIntrinsicContentSize()
        textViewDescribeMemo.fitTextToIntrinsicContentSize()
        
        textViewDescribeNecessity.removeSpaceOutsideRange()
        textViewDescribeAchievementStandard.removeSpaceOutsideRange()
        textViewDescribeMemo.removeSpaceOutsideRange()
        
    }
}

extension TaskCreateModalViewController: UITextFieldDelegate {
    //ユーザーが戻るボタンをタップした時に呼び出される。テキスト入力決定キー(return)でも呼び出される？
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じるメソッド
        textField.resignFirstResponder()
        return true
    }
}

extension TaskCreateModalViewController: UITextViewDelegate {
    //他の場所をタップしたらキーボードが消える
    //他のタスクビューにも実装
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if textViewDescribeNecessity.isFirstResponder {
            textViewDescribeNecessity.resignFirstResponder()
        } else if textViewDescribeAchievementStandard.isFirstResponder {
            textViewDescribeAchievementStandard.resignFirstResponder()
        } else if textViewDescribeMemo.isFirstResponder {
            textViewDescribeMemo.resignFirstResponder()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let placeTextView = textView as? PlaceTextView else { return }
        placeTextView.textDidChanged()
    }
}
