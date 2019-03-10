//
//  SelectGroupTableViewController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

class SelectGroupTableViewController: UITableViewController {

    var delegate: SelectGroupTableViewControllerDelegate?
    var selectedGroup: Group?
    private var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groups = DatabaseHelper.fetchGroups()
    }
}

// MARK: - Table view data source

extension SelectGroupTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectGroupCell", for: indexPath)
        cell.textLabel?.text = groups[indexPath.row].name
        if let selectedGroup = selectedGroup, groups[indexPath.row] == selectedGroup {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

// MARK: - Table view delegate

extension SelectGroupTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(group: groups[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Select group delegate

protocol SelectGroupTableViewControllerDelegate {
    func didSelect(group: Group)
}
