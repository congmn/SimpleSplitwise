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
    static var context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }()
    
    static func fetchPeople() -> [Person] {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        guard let people = try? context?.fetch(request) else { return [] }
        return people ?? []
    }
    
    static func fetchGroups() -> [Group] {
        let request: NSFetchRequest<Group> = Group.fetchRequest()
        guard let groups = try? context?.fetch(request) else { return [] }
        return groups ?? []
    }
}
