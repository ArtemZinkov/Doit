//
//  UITableView.swift
//  Doit
//
//  Created by Артём Зиньков on 9/12/19.
//  Copyright © 2019 Artem Zinkov. All rights reserved.
//

import UIKit

extension UITableView {
    open func register(cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass.self))
    }

    open func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: String(describing: cellClass.self), for: indexPath) as? T
    }
}
