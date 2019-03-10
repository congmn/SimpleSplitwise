//
//  GroupTableViewController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/7/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {
    
    private var groups: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        groups = DatabaseHelper.fetchGroups()
    }
}

// MARK: - Table view data source

extension GroupTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.textLabel?.text = groups[indexPath.row].name
        return cell
    }
}
