//
//  CalendarSelectViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/07/14.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import Algorithms

class CalendarSelectViewController: UITableViewController {
    weak var viewController: ViewController? = nil
    
    var displayOnOff: [Bool] = []
    var displayOut: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(self.displayOnOff)
        viewController!.displayCalendars = []
        for (index, calendar) in self.viewController!.calendars.indexed() {
            if displayOnOff[index] == true {
                viewController!.displayCalendars.append(calendar.title)
            }
        }
        print(viewController!.displayCalendars)
        UserDefaults.standard.set(viewController!.displayCalendars, forKey: "displayCalendars")
        
        print(self.displayOut)
        self.viewController!.displayOutCalendars = []
        for (index, calendar) in self.viewController!.calendars.indexed() {
            if self.displayOut[index] == true {
                self.viewController!.displayOutCalendars.append(calendar.title)
            }
        }
        print(self.viewController!.displayOutCalendars)
    
        self.viewController!.updateDays()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Select Calendar"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewController!.calendars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendar", for: indexPath) as! CalendarSelectViewCell
        cell.title.text = viewController!.calendars[indexPath.row].title
        cell.title.textColor = UIColor(red: viewController!.calendars[indexPath.row].cgColor.components![0],
                                       green: viewController!.calendars[indexPath.row].cgColor.components![1],
                                       blue: viewController!.calendars[indexPath.row].cgColor.components![2],
                                       alpha: 1.0)
        cell.index = indexPath.row
        cell.tableView = self
        if viewController!.displayCalendars.contains(viewController!.calendars[indexPath.row].title) == true {
            cell.display.isOn = true
            self.displayOnOff.append(true)
        }
        else {
            cell.display.isOn = false
            self.displayOnOff.append(false)

        }
        if viewController!.displayOutCalendars.contains(viewController!.calendars[indexPath.row].title) == true {
            cell.inOut.selectedSegmentIndex = 1
            self.displayOut.append(true)
        }
        else {
            cell.inOut.selectedSegmentIndex = 0
            self.displayOut.append(false)
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
