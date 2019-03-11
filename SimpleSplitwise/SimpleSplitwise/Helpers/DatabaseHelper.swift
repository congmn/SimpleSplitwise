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
        return people?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) ?? []
    }
    
    static func fetchGroups() -> [Group] {
        let request: NSFetchRequest<Group> = Group.fetchRequest()
        guard let groups = try? context?.fetch(request) else { return [] }
        return groups?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) ?? []
    }
    
    static func getExpenseDiary(ofPerson person: Person) -> String {
        guard let groups = person.groups?.allObjects as? [Group] else { return "Empty" }
        var result = ""
        for group in groups {
            guard let bills = group.bills?.allObjects as? [Bill] else { continue }
            let peopleInGroup = (group.members?.allObjects as? [Person])?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) ?? []
            let personIndex = peopleInGroup.firstIndex(of: person) ?? 0
            for bill in bills {
                guard let ruleDetails = bill.ruleDetails else { continue }
                let rule = SplitRule.rule(fromValue: Int(bill.rule))
                let ruleDetailsArray = ruleDetails.components(separatedBy: Constants.ruleDetailSeparator).map { Double($0) ?? 0.0 }
                let totalRuleValue = ruleDetailsArray.reduce(0, +)
                let personalRuleValue = ruleDetailsArray[personIndex]
                
                var expense = 0.0
                switch rule {
                case .equally:
                    expense = bill.amount / Double(peopleInGroup.count)
                case .exactAmount:
                    expense = personalRuleValue
                case .adjustment:
                    expense = (bill.amount - totalRuleValue) / Double(peopleInGroup.count) + personalRuleValue
                case .percent:
                    expense = bill.amount / 100 * personalRuleValue
                case .share:
                    expense = bill.amount / totalRuleValue * personalRuleValue
                }
                
                result += "Group: \(group.name ?? "") - Bill: \(bill.name ?? "") - Date: \(getDateString(fromDate: bill.date)) - Expense: \(String(format: "%.2f", expense))\n"
            }
        }
        return result.isEmpty ? "Empty" : result
    }
    
    static private func getDateString(fromDate date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        if let date = date {
            return dateFormatter.string(from: date)
        }
        return ""
    }
}
