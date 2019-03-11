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
            guard let bills = (group.bills?.allObjects as? [Bill])?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) else { continue }
            for bill in bills {
                let expense = getPersonalExpense(bill: bill, person: person)
                result += "Group: \(group.name ?? "") - Bill: \(bill.name ?? "") - Date: \(getDateString(fromDate: bill.date)) - Expense: $\(String(format: "%.2f", expense))\n"
            }
        }
        return result.isEmpty ? "Empty" : result
    }
    
    static func getOverallBalance(ofGroup group: Group) -> String {
        guard let members = (group.members?.allObjects as? [Person])?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }),
            let bills = (group.bills?.allObjects as? [Bill])?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) else { return "" }
        var debtMatrix: [[Double]] = Array(repeating: Array(repeating: 0.0, count: members.count), count: members.count)
        for bill in bills {
            guard let paidPerson = bill.paidPerson else { continue }
            let paidPersonIndex = members.firstIndex(of: paidPerson) ?? 0
            for (personIndex, person) in members.enumerated() where person != paidPerson {
                let personalExpense = getPersonalExpense(bill: bill, person: person)
                debtMatrix[personIndex][paidPersonIndex] += personalExpense
            }
        }
        
        var result = ""
        for bill in bills {
            result += "Bill: \(bill.name ?? "") - Date: \(getDateString(fromDate: bill.date)) - Paid Person: \(bill.paidPerson?.name ?? "") - Amount: $\(String(format: "%.2f", bill.amount)) - Split Rule: \(SplitRule.rule(fromValue: Int(bill.rule)).text)\n"
        }
        result += "\n"
        for i in 0..<members.count {
            for j in (i+1)..<members.count {
                guard let firstPerson = members[i].name, let secondPerson = members[j].name else { continue }
                result += "\(firstPerson) owns \(secondPerson) $\(String(format: "%.2f", debtMatrix[i][j]))\n"
                result += "\(secondPerson) owns \(firstPerson) $\(String(format: "%.2f", debtMatrix[j][i]))\n"
            }
        }
        return result
    }
    
    static private func getPersonalExpense(bill: Bill, person: Person) -> Double {
        guard let ruleDetails = bill.ruleDetails else { return 0.0 }
        let sortedPeople = (bill.group?.members?.allObjects as? [Person])?.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) ?? []
        let personIndex = sortedPeople.firstIndex(of: person) ?? 0
        let rule = SplitRule.rule(fromValue: Int(bill.rule))
        let ruleDetailsArray = ruleDetails.components(separatedBy: Constants.ruleDetailSeparator).map { Double($0) ?? 0.0 }
        let totalRuleValue = ruleDetailsArray.reduce(0, +)
        let personalRuleValue = rule == .equally ? 0.0 : ruleDetailsArray[personIndex]
        
        var expense = 0.0
        switch rule {
        case .equally:
            expense = bill.amount / Double(sortedPeople.count)
        case .exactAmount:
            expense = personalRuleValue
        case .adjustment:
            expense = (bill.amount - totalRuleValue) / Double(sortedPeople.count) + personalRuleValue
        case .percent:
            expense = bill.amount / 100 * personalRuleValue
        case .share:
            expense = bill.amount / totalRuleValue * personalRuleValue
        }
        return expense
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
