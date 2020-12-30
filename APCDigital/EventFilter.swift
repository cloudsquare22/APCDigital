//
//  EventFilter.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/12/30.
//  Copyright © 2020 shi-n. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Logging

extension EventFilter {
    static let logger = Logger()
    
    static func selectAll() -> [(calendar: String, filterString: String)] {
        var result: [(calendar: String, filterString: String)] = []
        logger.info()
        let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<EventFilter>(entityName: "EventFilter")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "calendar", ascending: true),
                                            NSSortDescriptor(key: "filterString", ascending: true)]
            let eventFilters: [EventFilter] = try managedObjectContext.fetch(fetchRequest)
            for eventFilter in eventFilters {
                result.append((calendar: eventFilter.calendar!, filterString: eventFilter.filterString!))
            }
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return result
    }

    static func insert(calendar: String, filterString: String) {
        logger.info()
        let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let eventFilter = EventFilter(context: managedObjectContext)
            eventFilter.calendar = calendar
            eventFilter.filterString = filterString
            try managedObjectContext.save()
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    static func delete(calendar: String, filterString: String) {
        logger.info()
        let managedObjectContext  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let predicate = NSPredicate(format: "calendar == %@ AND filterString == %@", calendar, filterString)
            let fetchRequest = NSFetchRequest<EventFilter>(entityName: "EventFilter")
            fetchRequest.predicate = predicate
            let eventFilters: [EventFilter] = try managedObjectContext.fetch(fetchRequest)
            if eventFilters.count > 0 {
                managedObjectContext.delete(eventFilters[0])
                try managedObjectContext.save()
            }
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

}
