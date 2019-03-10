//
//  SelectPaidPersonTableViewController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

class SelectPaidPersonTableViewController: UITableViewController {

    var delegate: SelectPaidPersonTableViewControllerDelegate?
    var selectedGroup: Group?
    var selectedPaidPerson: Person?
    private var people: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        people = selectedGroup?.members?.allObjects as? [Person] ?? []
    }
}

// MARK: - Table view data source

extension SelectPaidPersonTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPaidPersonCell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row].name
        if let selectedPaidPerson = selectedPaidPerson, people[indexPath.row] == selectedPaidPerson {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

// MARK: - Table view delegate

extension SelectPaidPersonTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(person: people[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Select paid person delegate

protocol SelectPaidPersonTableViewControllerDelegate {
    func didSelect(person: Person)
}
