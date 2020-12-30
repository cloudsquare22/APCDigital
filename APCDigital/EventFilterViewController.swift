//
//  EventFilterViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/12/28.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class EventFilterViewController: UITableViewController {
    weak var viewController: ViewController? = nil

    var eventFilters: [(calendar: String, filterString: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventFilters = EventFilter.selectAll()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Control"
        }
        else {
            return "Filters"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }
        else {
            return self.eventFilters.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "filters", for: indexPath) as! EventFilterViewCell
//        cell.viewController = self.viewController
        
        var cell: UITableViewCell? = nil
        
        print(indexPath)
        if indexPath.section == 0 {
            let addCell = tableView.dequeueReusableCell(withIdentifier: "addfilters", for: indexPath) as! EventFilterViewAddCell
            addCell.viewController = self.viewController
            addCell.setPicker()
            cell = addCell
        }
        else {
            let filterCell = tableView.dequeueReusableCell(withIdentifier: "filters", for: indexPath) as! EventFilterViewCell
            filterCell.calendar.text = self.eventFilters[indexPath.row].calendar
            filterCell.filterString.text = self.eventFilters[indexPath.row].filterString
            cell = filterCell
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100.0
        }
        else {
            return 50.0
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if indexPath.row != 0 {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            print(indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
