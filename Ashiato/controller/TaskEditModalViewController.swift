//
//  TaskEditModalViewController.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/12.
//

import UIKit

enum DisplayModeTaskEditModal {
    case common
    case nextTask
    case branchTask
}

class TaskEditModalViewController: UIViewController {
    @IBOutlet weak var textViewDescribeNecessity: PlaceTextView!
    @IBOutlet weak var textViewDescribeAchievementStandard: PlaceTextView!
    @IBOutlet weak var textViewDescribeMemo: PlaceTextView!
    @IBOutlet weak var textFieldShowTaskName: UITextField!
    @IBOutlet weak var buttonCreateNextTask: UIButton!
    @IBOutlet weak var buttonCreateBranchTask: UIButton!
    @IBOutlet weak var textFieldEditStartDate: DatePickTextField!
    @IBOutlet weak var textFieldEditGoalDate: DatePickTextField!
    @IBOutlet weak var statusChangeButton: StatusChangeButton!
    
    var displayMode:DisplayModeTaskEditModal = .common
    var taskData: TaskData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewDescribeNecessity.delegate = self
        textViewDescribeAchievementStandard.delegate = self
        textViewDescribeMemo.delegate = self
        textFieldShowTaskName.delegate = self
        
        textFieldEditStartDate.setup(viewWidth: view.frame.width, defaultDate: Date())
        textFieldEditGoalDate.setup(viewWidth: view.frame.width, defaultDate: Date())
        
        if let t = taskData {
            textFieldShowTaskName.text = t.title
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            textFieldEditStartDate.text = "\(formatter.string(from: t.startDate))"
            textFieldEditGoalDate.text = "\(formatter.string(from: t.completeDate))"
            textViewDescribeNecessity.text = t.necessity
            textViewDescribeAchievementStandard.text = t.achievementStandard
            textViewDescribeMemo.text = t.memo
            
            switch t.status {
            case 0:
                statusChangeButton.displayMode = .doing
            case 1:
                statusChangeButton.displayMode = .complete
            case 2:
                statusChangeButton.displayMode = .cancel
            default:
                break
            }
            statusChangeButton.setup()
            
            //もし延長タスクを所持しているなら、延長タスク作成ボタンを表示しない
            if t.nextTask != nil {
                buttonCreateNextTask.isEnabled = false
                buttonCreateNextTask.isHidden = true
            }
            
            
        }
        
        if displayMode == .nextTask {
            //延長元タスク名をタスク名表示テキストフィールドの上のラベルに書き込み
        } else if displayMode == .branchTask {
            //分岐元タスク名をタスク名表示テキストフィールドの上のラベルに書き込み
        }
        
        
        textViewDescribeNecessity.placeHolder = "なぜこのタスクが必要か書こう！"
        textViewDescribeAchievementStandard.placeHolder = "何をもって完了とするのか書こう！"
        textViewDescribeMemo.placeHolder = "タスクに関するメモを書こう！"
        
        textViewDidChange(textViewDescribeNecessity)
        textViewDidChange(textViewDescribeAchievementStandard)
        textViewDidChange(textViewDescribeMemo)
        
        textFieldEditStartDate.datePicker.minimumDate = taskData?.startDate
        textFieldEditGoalDate.datePicker.minimumDate = taskData?.completeDate
        
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        taskData?.title = textFieldShowTaskName.text ?? ""
        taskData?.achievementStandard = textViewDescribeAchievementStandard.text
        taskData?.necessity = textViewDescribeNecessity.text
        taskData?.memo = textViewDescribeMemo.text
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        guard let startDate =  formatter.date(from: textFieldEditStartDate.text ?? "") else {
            return
        }
        guard let completeDate =  formatter.date(from: textFieldEditGoalDate.text ?? "") else {
            return
        }
        
        if taskData!.completeDate < completeDate {
            if taskData?.extendHistory == nil {
                taskData?.extendHistory = [taskData!.completeDate]
            } else {
                taskData?.extendHistory?.append(taskData!.completeDate)
            }
            
        }
        
        taskData?.startDate = startDate
        taskData?.completeDate = completeDate
        taskData?.status = statusChangeButton.displayMode!.rawValue
        
        if let viewController = presentingViewController as? ViewController {
            viewController.collectionView.reloadData()
        }
        
    }
    
    @IBAction func statusChangeButton(_ sender: Any) {
        statusChangeButton.statusChange()
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
    @IBAction func tapButtonCreateNextTask(_ sender: Any) {
        
        let modalStoryBoard = UIStoryboard(name: "NextAndBranchTaskCreateModal", bundle: nil)
        
        guard let modalViewController = modalStoryBoard.instantiateInitialViewController() as? NextAndBranchTaskCreateModalViewController else { return }
        modalViewController.displayMode = .nextTask
        modalViewController.parentTaskData = taskData
        present(modalViewController, animated: true)
        
        
    }
    @IBAction func tapButtonCreateBranchTask(_ sender: Any) {
        let modalStoryBoard = UIStoryboard(name: "NextAndBranchTaskCreateModal", bundle: nil)
        
        guard let modalViewController = modalStoryBoard.instantiateInitialViewController() as? NextAndBranchTaskCreateModalViewController else { return }
        modalViewController.displayMode = .branchTask
        modalViewController.parentTaskData = taskData
        present(modalViewController,animated: true)
        
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
