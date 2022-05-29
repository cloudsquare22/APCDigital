//
//  EditEventsViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/23.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import EventKit

class EditEventsViewController: UITableViewController {
    weak var viewController: ViewController? = nil

    var eventStore = EKEventStore()
    var events = [EKEvent]()

    let storyBoard = UIStoryboard(name: "Main", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setEvents()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Events"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "events", for: indexPath) as! EditEventsViewCell
        cell.calendarImage.tintColor = UIColor(red: events[indexPath.row].calendar.cgColor.components![0],
                                               green: events[indexPath.row].calendar.cgColor.components![1],
                                               blue: events[indexPath.row].calendar.cgColor.components![2],
                                               alpha: 1.0)
        cell.eventText.text = events[indexPath.row].title
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        
        if events[indexPath.row].isAllDay == true {
            dateFormatter.dateFormat = "MM/dd"
        }
        else {
            dateFormatter.dateFormat = "MM/dd HH:mm〜"
        }

        cell.startDate.text = dateFormatter.string(from: events[indexPath.row].startDate)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editScheduleViewController = self.storyBoard.instantiateViewController(withIdentifier: "EditScheduleView") as? EditScheduleViewController
        if let controller = editScheduleViewController {
            let event = self.events[indexPath.row]
            controller.viewController = self.viewController
            controller.startDate = event.startDate
            controller.endDate = event.endDate
            controller.baseEvent = event
            controller.eventStore = self.eventStore
            controller.preferredContentSize = CGSize(width: 600, height: 450)
            self.present(controller, animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            print("Event Delete")
//            do {
//                try self.eventStore.remove(eventStore.event(withIdentifier: self.events[indexPath.row].eventIdentifier)!, span: .thisEvent)
//                self.viewController?.pageUpsert()
//                self.viewController?.updateDays()
//                self.setEvents()
//            }
//            catch {
//                let nserror = error as NSError
//                print(nserror)
//            }
//        }
//        self.tableView.reloadData()
//    }
    
    func setEvents() {
        self.events = []
        let eventArray = self.viewController!.getEvents()
        let nationalHoliday = self.viewController!.nationalHolidayCalendarName
        for event in eventArray {
            if event.calendar.title == nationalHoliday {
                continue
            }
            switch event.calendar.type {
            case .local, .calDAV:
                events.append(event)
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal  , title: "edit") {
                    (ctxAction, view, completionHandler) in
            
                     print("edit")
            self.dismiss(animated: true)
            let editScheduleViewController = self.storyBoard.instantiateViewController(withIdentifier: "EditScheduleView") as? EditScheduleViewController
            if let controller = editScheduleViewController {
                let event = self.events[indexPath.row]
                controller.viewController = self.viewController
                controller.startDate = event.startDate
                controller.endDate = event.endDate
                controller.baseEvent = event
                controller.eventStore = self.eventStore
                self.viewController!.setPopoverPresentationController(size: CGSize(width: 600, height: 450),
                                                      rect: CGRect(x: self.view.frame.width / 2, y: 10, width: 1, height: 1),
                                                      controller: controller)
                self.viewController!.present(controller, animated: false, completion: nil)
            }
                    completionHandler(true)
                }
        let editImage = UIImage(systemName: "pencil")?.withTintColor(UIColor.white, renderingMode: .alwaysTemplate)
        editAction.image = editImage
        editAction.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 255/255, alpha: 1)

        let deleteAction = UIContextualAction(style: .destructive, title:"delete") { (ctxAction, view, completionHandler) in
            print("Event Delete")
            do {
                try self.eventStore.remove(self.eventStore.event(withIdentifier: self.events[indexPath.row].eventIdentifier)!, span: .thisEvent)
                self.viewController?.pageUpsert()
                self.viewController?.updateDays()
                self.setEvents()
            }
            catch {
                let nserror = error as NSError
                print(nserror)
            }
            completionHandler(true)
            self.tableView.reloadData()
        }
        let trashImage = UIImage(systemName: "trash.fill")?.withTintColor(UIColor.white , renderingMode: .alwaysTemplate)
        deleteAction.image = trashImage
        deleteAction.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        
        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction, editAction])
        swipeAction.performsFirstActionWithFullSwipe = false
                
        return swipeAction
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
