//
//  TaskListModel.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import Foundation

struct TaskListModel: Decodable {
    let tasks: [TaskModel]
    let meta: Meta
    
    struct Meta: Decodable {
        let current: Int
        let limit: Int
        let count: Int
    }
}
