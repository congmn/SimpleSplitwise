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
        people = fetchPeople()
    }
    
    @IBAction func addPerson(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Person", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] alert in
            guard let textField = alertController.textFields?.first, let name = textField.text else { return }
            self?.savePerson(withName: name)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func fetchPeople() -> [Person] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        guard let people = try? context.fetch(request) else { return [] }
        return people
    }
    
    private func savePerson(withName name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let person = Person(context: context)
        person.name = name
        appDelegate.saveContext()
        
        people = fetchPeople()
        tableView.reloadData()
    }
}

// MARK: - Table view data source

extension PersonTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        cell.textLabel?.text = people[indexPath.row].name
        return cell
    }
}
