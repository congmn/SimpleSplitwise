//
//  PersonTableViewController.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/7/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit
import CoreData

class PersonTableViewController: UITableViewController {
    
    private var people: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        people = DatabaseHelper.fetchPeople()
    }
    
    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        AlertController.shared.showInputAlert(title: "Add Person", message: "", confirmTitle: "Save", cancelTitle: "Cancel", keyboardType: .default, placeholder: "Name") { [weak self] (confirmed, text) in
            if confirmed, let name = text {
                self?.savePerson(withName: name)
            }
        }
    }
    
    private func savePerson(withName name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let person = Person(context: context)
        person.name = name
        appDelegate.saveContext()
        
        people = DatabaseHelper.fetchPeople()
        tableView.reloadData()
    }
}

// MARK: - Table view data source

extension PersonTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row].name
        return cell
    }
}
