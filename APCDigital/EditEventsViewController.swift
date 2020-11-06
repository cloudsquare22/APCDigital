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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            print("Event Delete")
            do {
                try self.eventStore.remove(eventStore.event(withIdentifier: self.events[indexPath.row].eventIdentifier)!, span: .thisEvent)
                self.viewController?.pageUpsert()
                self.viewController?.updateDays()
                self.setEvents()
            }
            catch {
                let nserror = error as NSError
                print(nserror)
            }
        }
        self.tableView.reloadData()
    }
    
    func setEvents() {
        self.events = []
        let eventArray = self.viewController!.getEvents()
        var nationalHoliday = "日本の祝日"
        if let title = UserDefaults.standard.string(forKey: "nationalHoliday") {
            nationalHoliday = title
        }
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
