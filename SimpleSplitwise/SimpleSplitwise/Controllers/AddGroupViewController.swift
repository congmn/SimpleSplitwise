//
//  AddGroupViewController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var membersTableView: UITableView!
    private var people: [Person] = []
    private var selectedPeopleIndex: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupNameTextField.delegate = self
        people = DatabaseHelper.fetchPeople()
    }
    
    @IBAction func cancelAddGroup(_ sender: UIBarButtonItem) {
        dismissScreen()
    }
    
    @IBAction func saveNewGroup(_ sender: UIBarButtonItem) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let groupName = groupNameTextField.text,
            !groupName.isEmpty && !selectedPeopleIndex.isEmpty else {
            dismissScreen()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let group = Group(context: context)
        group.name = groupName
        for index in selectedPeopleIndex where people.indices.contains(index) {
            group.addToMembers(people[index])
        }
        appDelegate.saveContext()
        dismissScreen()
    }
    
    private func dismissScreen() {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Table view data source

extension AddGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroupTableViewCell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row].name
        cell.accessoryType = selectedPeopleIndex.contains(indexPath.row) ? .checkmark : .none
        return cell
    }
}

// MARK: - Table view delegate

extension AddGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        if selectedCell.accessoryType == .none {
            selectedCell.accessoryType = .checkmark
            selectedPeopleIndex.append(indexPath.row)
        } else {
            selectedCell.accessoryType = .none
            selectedPeopleIndex = selectedPeopleIndex.filter { $0 != indexPath.row }
        }
    }
}

// MARK: - Text field delegate

extension AddGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
