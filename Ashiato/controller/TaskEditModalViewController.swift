//
//  TaskEditModalViewController.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/12.
//

import UIKit

class TaskEditModalViewController: UIViewController {
    @IBOutlet weak var textViewDescribeNecessity: PlaceTextView!
    @IBOutlet weak var textViewDescribeAchievementStandard: PlaceTextView!
    @IBOutlet weak var textViewDescribeMemo: PlaceTextView!
    @IBOutlet weak var textFieldShowTaskName: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewDescribeNecessity.delegate = self
        textViewDescribeAchievementStandard.delegate = self
        textViewDescribeMemo.delegate = self
        textFieldShowTaskName.delegate = self
 
        textViewDescribeNecessity.placeHolder = "なぜこのタスクが必要か書こう！"
        textViewDescribeAchievementStandard.placeHolder = "何をもって完了とするのか書こう！"
        textViewDescribeMemo.placeHolder = "タスクに関するメモを書こう！"
        
        textViewDidChange(textViewDescribeNecessity)
        textViewDidChange(textViewDescribeAchievementStandard)
        textViewDidChange(textViewDescribeMemo)
        
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
        //setumeiTextViewがFirstResponderである場合(setumeiTextViewがイベント処理中(編集中)である場合?)
        
        if textViewDescribeNecessity.isFirstResponder || textViewDescribeAchievementStandard.isFirstResponder || textViewDescribeMemo.isFirstResponder {
            //sender.userInfoは通知を送る際に追加で送られるデータ
            guard let userInfo = sender.userInfo else { return }
            //durationは間隔という意味
            //keyboardAnimationDurationUserInfoKeyはキーボードの表示アニメーションにかかる時間
            let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
            //キーボードの高さを取得
              guard let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            
            //CGAffineTransformによるビューの縦移動
            //CGAffineTransformによる移動のメリット
            UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
                var textViewMinY: CGFloat = 0
                if self.textViewDescribeNecessity.isFirstResponder {
                    textViewMinY = self.view.convert(self.textViewDescribeNecessity.frame, from: self.textViewDescribeNecessity.superview).minY
                } else if self.textViewDescribeAchievementStandard.isFirstResponder {
                    textViewMinY = self.view.convert(self.textViewDescribeAchievementStandard.frame, from: self.textViewDescribeAchievementStandard.superview).minY
                } else if self.textViewDescribeMemo.isFirstResponder {
                    textViewMinY = self.view.convert(self.textViewDescribeMemo.frame, from: self.textViewDescribeMemo.superview).minY
                }
                let destinationY = (self.view.frame.height - keyboardRect.height) / 2
                let transform = CGAffineTransform(translationX: 0, y: destinationY - textViewMinY)
                self.view.transform = transform
                
            })
 
        }
    }
    
    @objc
    private func keyboardWillHide(sender: NSNotification) {
        guard let userInfo = sender.userInfo else { return }
        let duration: Float = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
            //self.view.center.y -= self.view.frame.minY - self.textViewDescribeMemo.frame.minY
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //注目されているテキストビューがない場合、全てのテキストビューに対して、ある場合、そのテキストビューに対して処理を行うようにする！
        
        textViewDescribeNecessity.fitTextToIntrinsicContentSize()
        textViewDescribeAchievementStandard.fitTextToIntrinsicContentSize()
        textViewDescribeMemo.fitTextToIntrinsicContentSize()
        
        textViewDescribeNecessity.removeSpaceOutsideRange()
        textViewDescribeAchievementStandard.removeSpaceOutsideRange()
        textViewDescribeMemo.removeSpaceOutsideRange()
        
    }
    
}

extension TaskEditModalViewController: UITextFieldDelegate {
    //ユーザーが戻るボタンをタップした時に呼び出される。テキスト入力決定キー(return)でも呼び出される？
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じるメソッド
        textField.resignFirstResponder()
        return true
    }
}

extension TaskEditModalViewController: UITextViewDelegate {
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
