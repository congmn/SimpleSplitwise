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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groups = DatabaseHelper.fetchGroups()
        tableView.reloadData()
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

// MARK: - Table view delegate

extension GroupTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        AlertController.shared.showMessageAlert(title: "Overall Balance", message: DatabaseHelper.getOverallBalance(ofGroup: groups[indexPath.row]))
    }
}
