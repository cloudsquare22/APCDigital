//
//  Pages.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/04.
//  Copyright © 2020 shi-n. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Logging

extension Pages {
    static func createPredicateYearAndWeek(_ year: Int, _ week: Int) -> NSPredicate {
        return NSPredicate(format: "year == %@ AND week == %@", String(year), String(week))
    }
    
    static func select(year: Int, week: Int) -> Data? {
        var result: Data? = nil
        let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<Pages>(entityName: "Pages")
            fetchRequest.predicate = createPredicateYearAndWeek(year, week)
            let pages: [Pages] = try managedObjectContext.fetch(fetchRequest)
            print(pages)
            if pages.count > 0 {
                result = pages[0].page
            }
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return result
    }
    
    static func selectAll() -> [(year: Int , week: Int)] {
        var result: [(year: Int , week: Int)] = []
        let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<Pages>(entityName: "Pages")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true),
                                            NSSortDescriptor(key: "week", ascending: true)]
            let pages: [Pages] = try managedObjectContext.fetch(fetchRequest)
            print(pages)
            for page in pages {
                result.append((year: Int(page.year), week: Int(page.week)))
            }
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return result
    }
    
    static func upsert(year: Int, week: Int, page: Data) {
        let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<Pages>(entityName: "Pages")
            fetchRequest.predicate = createPredicateYearAndWeek(year, week)
            let pages: [Pages] = try managedObjectContext.fetch(fetchRequest)
            print(pages)
            
            if pages.count == 0 {
                let newPage = Pages(context: managedObjectContext)
                newPage.year = Int16(year)
                newPage.week = Int16(week)
                newPage.page = page
                print(newPage)
                print("insert")
            }
            else {
                let updatePage = pages[0]
                updatePage.page = page
                print(updatePage)
                print("update")
            }
            try managedObjectContext.save()
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    static func delete(year: Int, week: Int) {
        let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<Pages>(entityName: "Pages")
            fetchRequest.predicate = createPredicateYearAndWeek(year, week)
            let pages: [Pages] = try managedObjectContext.fetch(fetchRequest)
            print(pages)
            if pages.count > 0 {
                managedObjectContext.delete(pages[0])
                try managedObjectContext.save()
            }
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
