//
//  AccountScreen.swift
//  Ashiato
//
//  Created by 山田純平 on 2021/09/19.
//

import UIKit

class AccountScreenViewController: UIViewController {
    @IBOutlet weak var userImage: UIImageView! {
        didSet {
            userImage.layer.cornerRadius = userImage.frame.height/2
        }
    }
    @IBOutlet weak var taskNotificationTableView: UITableView!
    @IBOutlet weak var editProfileButton: UIButton! {
        didSet {
            editProfileButton.layer.borderColor = editProfileButton.currentTitleColor.cgColor
            editProfileButton.layer.borderWidth = 1
            editProfileButton.layer.cornerRadius = 10
        }
    }
    
    override func viewDidLoad() {
        taskNotificationTableView.delegate = self
        taskNotificationTableView.dataSource = self
        let nib = UINib(nibName: "TaskNotificationTableViewCell", bundle: nil)
            taskNotificationTableView.register(nib, forCellReuseIdentifier: "TaskNotificationTableViewCell")
        taskNotificationTableView.estimatedRowHeight = 100
        
    }
}

extension AccountScreenViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskNotificationTableView.dequeueReusableCell(withIdentifier: "TaskNotificationTableViewCell")!
        return cell
    }
    
    
}
