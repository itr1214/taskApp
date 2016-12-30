//
//  ViewController.swift
//  taskApp
//
//  Created by 岡田 一郎 on 2016/12/17.
//  Copyright © 2016年 Ichirou Okada. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications


class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var SearchBar: UISearchBar!

    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でそーと：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
    
    var predicate:NSPredicate?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        tableView.delegate = self
        tableView.dataSource = self
        
        SearchBar.delegate = self;

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数(=セルの数)を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if predicate != nil && SearchBar.text?.isEmpty == false {
            taskArray = realm.objects(Task.self).filter(predicate!)
        }
        return taskArray.count
    }
  
    // 格セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        var dateString:String?

        print("if 外\(predicate)")
        // 検索条件が入力されている場合
        if predicate != nil && SearchBar.text?.isEmpty != true{

            let search = taskArray[indexPath.row]
            cell.textLabel?.text = search.title
            dateString = formatter.string(from: search.date as Date)
            cell.detailTextLabel?.text = dateString
            
        } else {
            var task = taskArray[indexPath.row]
            task = taskArray[indexPath.row]
            cell.textLabel?.text = task.title

            dateString = formatter.string(from: task.date as Date)
            cell.detailTextLabel?.text = dateString
        }
        return cell
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 格セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能な事を伝えるメソッド
    @objc(tableView:editingStyleForRowAtIndexPath:) func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath:IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            // データベースから削除する
            try! realm.write {
                 self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
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
    }
    
    // segue で画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 文字列が含まれていたら
        if SearchBar.text!.isEmpty == false {
            predicate = NSPredicate(format: "category = %@", argumentArray: ["\(SearchBar.text!)"])
        } else {
            taskArray =  try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
        }
        
        tableView.reloadData()
    }
    
    // Cancelボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cansel")
        SearchBar.text = ""
        taskArray =  try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
        predicate = nil
        tableView.reloadData()
    }
    
    // 入力画面から戻ってきたときに　TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
    }
    

}

