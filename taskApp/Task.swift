//
//  Task.swift
//  taskApp
//
//  Created by 岡田 一郎 on 2016/12/23.
//  Copyright © 2016年 Ichirou Okada. All rights reserved.
//

import RealmSwift

class Task: Object {
    //管理用　ID,プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    // 日時
    dynamic var date = NSDate()
    
    // カテゴリー
    dynamic var category = ""
    
    /**
     id　をプライマリーキーとして設定
     */
    
    override static func primaryKey() -> String? {
        return "id"
    }
 
}

