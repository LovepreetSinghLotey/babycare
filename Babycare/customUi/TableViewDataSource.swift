//
//  tableViewDataSource.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import Foundation
import UIKit

class TableViewDataSource<CELL: UITableViewCell, T>: NSObject, UITableViewDataSource{
    
    private var cellIdentifier: String!
    private var items: [T]!
    var configureCell: (CELL, T) -> () = {_, _ in }
    
    init(cellIdentifier: String, items: [T], configureCell: @escaping (CELL, T) -> ()) {
        self.cellIdentifier = cellIdentifier
        self.items = items
        self.configureCell = configureCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CELL = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CELL
        self.configureCell(cell, items[indexPath.row])
        return cell
    }
}
