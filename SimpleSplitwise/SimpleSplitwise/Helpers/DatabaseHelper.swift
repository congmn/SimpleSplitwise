//
//  DatabaseHelper.swift
//  SimpleSplitwise
//
//  Created by Cong Nguyen on 3/10/19.
//  Copyright © 2019 Cong Nguyen. All rights reserved.
//

import UIKit
import CoreData

struct DatabaseHelper {
    static func fetchPeople() -> [Person] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        guard let people = try? context.fetch(request) else { return [] }
        return people
    }
    
    static func fetchGroups() -> [Group] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Group> = Group.fetchRequest()
        guard let groups = try? context.fetch(request) else { return [] }
        return groups
    }
}
