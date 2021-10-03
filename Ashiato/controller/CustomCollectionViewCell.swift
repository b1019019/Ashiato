//
//  CustomCollectionViewCell.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/22.
//

import UIKit

extension Notification.Name {
    static let scrollTableView = Notification.Name("scrollTableView")
}

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "tableViewCell")
        
        //スクロール時に送られた通知を受け取り、receiveScrollNotificationを実行
        NotificationCenter.default.addObserver(self, selector: #selector(receiveScrollNotification(notification:)), name: .scrollTableView, object: nil)
    }
    
    @objc func receiveScrollNotification(notification: NSNotification) {
        //全てのテーブルビューの高さを合わせる
        guard let asTableView = notification.object as? UITableView else {
            return
        }
        //print("高さ合わせ前",tableView.contentOffset.y,tableView.tag,asTableView.tag)
        if asTableView.tag != tableView.tag {
            tableView.contentOffset.y = asTableView.contentOffset.y
        }
        //print("高さ合わせ後",tableView.contentOffset.y,tableView.tag,asTableView.tag)
        
    }
    
    
    
    //テーブルビューのDataSource(表示する内容)とDelegate(テーブルビューの表示、操作)の権限委譲
    func setTableViewDataSourceDelegate
    <D: UITableViewDataSource & UITableViewDelegate>
    (dataSourceDelegate: D, forRow row: Int) {
        tableView.delegate = dataSourceDelegate
        tableView.dataSource = dataSourceDelegate
        //tagにCollectionViewのrowを設定させ、それによりテーブルビューの内容を変える
        tableView.tag = row
        //tableViewのデリゲート、データソースの関数を実行させる
        tableView.reloadData()
    }
}
