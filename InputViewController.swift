//
//  InputViewController.swift
//  taskApp
//
//  Created by 岡田 一郎 on 2016/12/20.
//  Copyright © 2016年 Ichirou Okada. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dataPicker: UIDatePicker!
    
    @IBOutlet weak var category: UITextField!
    var task: Task!
    var realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentTextView.text = task.contents
        dataPicker.date = task.date as Date
        category.text = task.category

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func dismissKeyboard() {
        // キーボードを閉じる
        view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentTextView.text!
            self.task.date = self.dataPicker.date as NSDate
            self.task.category = self.category.text!
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    // プッシュ通知に関する処理
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.contents
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtriggar(日付マッチ)を作成
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifir,content, triggarからローカル通知を作成(identifierが同じだと上書き保存)
        let request = UNNotificationRequest.init(identifier: String(task.id), content:content, trigger: trigger)
        
        // ローカル通知を登録する
        let center = UNUserNotificationCenter.current()
        center.add(request){
            (error) in
//            print(error)
            
        }
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests{(requests:[UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
            
        
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
