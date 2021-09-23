//
//  CustomTableViewCell.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/22.
//

import UIKit

extension Notification.Name {
    static let tableViewCellTap = Notification.Name("tableViewCellTap")
}

class CustomTableViewCell: UITableViewCell {
    
    var leftEndDate: Date? = calendar.date(from: DateComponents(year: 2021, month: 8, day: 21))
    
    var path = UIBezierPath()
    var shapeLayer = CAShapeLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // タップジェスチャーを作成
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        // 1タップで反応するように設定
        tapGesture.numberOfTapsRequired = 1
        // ビューにジェスチャーを設定
        self.addGestureRecognizer(tapGesture)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @discardableResult
    func addTaskCell(taskData: TaskData) -> TaskView?{
        //shapeLayerの大きさ設定
        //awakeFromNib時に行うと、heightForRowAtのTVセルの大きさ設定が適用されていない。なのでshapeLayer.frameの大きさ設定がおかしくなる
        shapeLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        //右端の日
        let rightEndDate = calendar.date(byAdding: .day, value: 3, to: leftEndDate!)!
        //左と右を丸角にするかどうか
        var leftCornerRounded = false
        var rightCornerRounded = false
        
        ////TaskViewの大きさ設定、startの設定、丸角の設定
        
        //左端日を基準としたタスクの開始日、完了日
        var start = 0
        var goal = 3
        
        if leftEndDate! <= taskData.startDate && taskData.startDate <= rightEndDate {
            start = calendar.dateComponents([.day], from: leftEndDate!, to: taskData.startDate).day!
            leftCornerRounded = true
        } else if rightEndDate < taskData.startDate {
            //addViewを描画せずに背景横線の描画を描画して終了。
            if let parent = taskData.parentTask {
                
                if parent.startDate < leftEndDate! {
                    horizontalDraw(startX: bounds.minX, goalX: bounds.maxX)
                } else if leftEndDate! <= parent.startDate && parent.startDate <= rightEndDate {
                    let gapParent = calendar.dateComponents([.day], from: leftEndDate!, to: parent.startDate).day!
                    horizontalDrawFromTop(startX: 10 + CGFloat(gapParent) * self.bounds.width/4, goalX: bounds.maxX)
                }
            }
            shapeLayer.path = path.cgPath
            shapeLayer.lineWidth = 5.0
            //色塗らんと見えない
            shapeLayer.strokeColor = UIColor.cyan.cgColor
            
            self.layer.addSublayer(shapeLayer)
            
            
            return nil
            
        }
        
        if leftEndDate! <= taskData.completeDate && taskData.completeDate <= rightEndDate {
            goal = calendar.dateComponents([.day], from: leftEndDate!, to: taskData.completeDate).day!
            rightCornerRounded = true
        } else if taskData.completeDate < leftEndDate! {
            //表示されない
            ////////
            if let next = taskData.nextTask {
                if let nextTaskView = addTaskCell(taskData: next){
                    ////////ベジエパス描画
                    if leftEndDate! <= next.startDate && next.startDate <= rightEndDate {
                        nextTaskView.horizontalConnect()
                        horizontalDraw(startX: 0, goalX: nextTaskView.frame.minX)
                    }
                    /////////
                    shapeLayer.path = path.cgPath
                    shapeLayer.lineWidth = 5.0
                    //色塗らんと見えない
                    shapeLayer.strokeColor = UIColor.cyan.cgColor
                    
                    self.layer.addSublayer(shapeLayer)
                    
                    
                    return nextTaskView
                }
            }
            
            return nil
            ////////
        }
        
        let addViewPath = UIBezierPath()
        let addView = TaskView(frame: CGRect(x: CGFloat(start) * (self.frame.width/4), y: 0, width: CGFloat(goal - start + 1) * self.frame.width/4, height: self.frame.height),task: taskData,path: addViewPath)
        
        ////
        
        
        
        let originX = addView.frame.origin.x
        //2つ目のインデックス
        var indexDate2 = leftEndDate!
        indexDate2 = calendar.date(byAdding: .day, value: start, to: indexDate2)!
        var lastExtendGoal = start
        
        //延長履歴を表示
        if let exDates = taskData.extendHistory {
            for i in start...3 {
                if exDates.contains(indexDate2) {
                    //startからこのDateの右端まで横線
                    //スタートの代わりの変数を用意して前の縦線を引いたDateを保存する。次延長日時が見つかった時、この縦線の隣から横線を引く
                    addView.extendDraw(exStart: CGFloat(lastExtendGoal) * self.frame.width/4 - originX, exGoal: CGFloat(i + 1) * self.frame.width/4 - originX)
                    lastExtendGoal = i + 1
                }
                indexDate2 = calendar.date(byAdding: .day, value: 1, to: indexDate2)!
            }
            //表示している4日よりも大きい日が出た時
            if exDates.contains(where: {(element) -> Bool in return rightEndDate < element } ) {
                //タスク終わりまで横線を引く
                addView.horizontalDraw(exStart: CGFloat(lastExtendGoal) * self.frame.width/4 - originX, exGoal: addView.frame.maxX)
                
            }
        }
        
        //分岐タスクを表示
        //自分が分岐の親だった場合
        if let branch = taskData.branchTask {
            if leftEndDate! <= taskData.startDate && taskData.startDate <= rightEndDate {
                addView.downConnect()
            }
            
        }
        //自分が分岐の子だった場合
        if let parent = taskData.parentTask {
            //親タスクの開始日が表示されている4日間より過去である場合
            if parent.startDate < leftEndDate! {
                //子タスクの開始日が左端日だった場合
                if  leftEndDate! <= taskData.startDate && taskData.startDate <= rightEndDate {
                    //TVC自身にタスク開始日まで横点線を引く
                    let gap = calendar.dateComponents([.day], from: leftEndDate!, to: taskData.startDate).day!
                    
                    horizontalDraw(startX: shapeLayer.bounds.minX, goalX: CGFloat(gap) * self.bounds.width/4)
                    
                    //addViewに丸と横点線を引く
                    addView.horizontalConnect()
                    
                }
                //親タスクの開始日が表示されている4日間のどれかである場合
            } else if leftEndDate! <= parent.startDate && parent.startDate <= rightEndDate {
                let gapParent = calendar.dateComponents([.day], from: leftEndDate!, to: parent.startDate).day!
                let gap = calendar.dateComponents([.day], from: leftEndDate!, to: taskData.startDate).day!
                
                if parent.startDate == taskData.startDate {
                    //addViewに縦線と丸を書く
                    addView.upConnect()
                } else if parent.startDate < taskData.startDate && taskData.startDate <= rightEndDate {
                    
                    //TVCに直接描画
                    horizontalDrawFromTop(startX: 10 + CGFloat(gapParent) * self.bounds.width/4, goalX: CGFloat(gap) * self.bounds.width/4)
                    
                    //addViewに丸と横点線を引く
                    addView.horizontalConnect()
                }
            }
            
        }
        
        //継続タスクを表示
        //継続タスクを所持していた場合
        if let next = taskData.nextTask {
            addView.horizontalConnectRight()
            if let nextTaskView = addTaskCell(taskData: next){
                nextTaskView.horizontalConnect()
                horizontalDraw(startX: addView.frame.maxX, goalX: nextTaskView.frame.minX)
            } else {
                horizontalDraw(startX: addView.frame.maxX, goalX: bounds.maxX)
            }
        }
        
        //角丸化
        addView.cornerRadius(leftCornerRounded: leftCornerRounded, rightCornerRounded: rightCornerRounded)
        
        addView.backgroundColor = UIColor.red
        addView.alpha = 0.6
        
        //self.frame.origin.xは値が動く
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: addView.frame.width, height: addView.frame.height))
        label.text = taskData.title
        label.textAlignment = NSTextAlignment.center
        addView.addSubview(label)
        
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 5.0
        //色塗らんと見えない
        shapeLayer.strokeColor = UIColor.cyan.cgColor
        
        self.addSubview(addView)
        
        self.layer.addSublayer(shapeLayer)
        
        /*
         path.move(to: CGPoint(x: 0, y: shapeLayer.frame.midY))
         path.addLine(to: CGPoint(x: shapeLayer.frame.maxX, y: shapeLayer.frame.midY))
         shapeLayer.lineWidth = 10.0
         shapeLayer.strokeColor = UIColor.cyan.cgColor
         shapeLayer.path = path.cgPath
         //shapeLayer.backgroundColor = UIColor.black.cgColor
         layer.addSublayer(shapeLayer)
         */
        
        return addView
    }
    
    private func addNextTaskCell(taskData: TaskData,addView: TaskView) {
        if let next = taskData.nextTask {
            if let nextTaskView = addTaskCell(taskData: next){
                nextTaskView.horizontalConnect()
                addView.horizontalConnectRight()
                horizontalDraw(startX: addView.frame.maxX, goalX: nextTaskView.frame.minX)
            } else {
                horizontalDraw(startX: addView.frame.maxX, goalX: bounds.maxX)
            }
        }
    }
    
    private func horizontalDraw(startX: CGFloat,goalX: CGFloat) {
        path.move(to: CGPoint(x: startX, y: bounds.midY))
        path.addLine(to: CGPoint(x: goalX, y: bounds.midY))
    }
    
    private func horizontalDrawFromTop(startX: CGFloat,goalX: CGFloat) {
        path.move(to: CGPoint(x: startX, y: bounds.minY))
        path.addLine(to: CGPoint(x: startX, y: bounds.midY))
        horizontalDraw(startX: startX, goalX: goalX)
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        print("TVC tapped",self.tag)
        NotificationCenter.default.post(name: .tableViewCellTap, object: nil)
    }
    
    
    func test (row: Int) {
        
        let sl = CAShapeLayer()
        //フレームの大きさが原因？、バグ発生から解決までの道のりを書き残す
        //frame.origin.xと0の違い！！
        sl.frame = CGRect(x: 0, y: 0, width: frame.width * CGFloat(row+1)/4, height: frame.height)
        sl.backgroundColor = UIColor.black.cgColor
        let p = UIBezierPath()
        p.move(to: CGPoint(x: 0, y: sl.frame.midY))
        p.addLine(to: CGPoint(x: sl.frame.maxX, y: sl.frame.midY))
        sl.path = p.cgPath
        sl.lineWidth = 5.0
        sl.strokeColor = UIColor.cyan.cgColor
        layer.addSublayer(sl)
    }
    
    func removeAllSubviews(){
        let subviews = self.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    func removeAllShapeLayers() {
        if let layers = self.layer.sublayers{
            for layer in layers {
                if let shapeLayer = layer as? CAShapeLayer {
                    shapeLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        //path.stroke()
        
        
    }
    
}
