//
//  SettingViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/04.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    weak var viewController: ViewController? = nil

    @IBOutlet weak var movementSymbols: UITextField!
    @IBOutlet weak var nationalHoliday: UITextField!
    
    @IBOutlet weak var dateAllDay: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let symbols = UserDefaults.standard.string(forKey: "movementSymbols") {
            movementSymbols.text = symbols
        }
        if let title = UserDefaults.standard.string(forKey: "nationalHoliday") {
            nationalHoliday.text = title
        }
        let dateAllDayH = UserDefaults.standard.integer(forKey: "dateAllDayH")
        let dateAllDayM = UserDefaults.standard.integer(forKey: "dateAllDayM")
        var dateComponentsAllDay = Calendar.current.dateComponents(in: .current, from: Date())
        dateComponentsAllDay.hour = dateAllDayH
        dateComponentsAllDay.minute = dateAllDayM
        self.dateAllDay.date = dateComponentsAllDay.date!
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let symbols = self.movementSymbols.text {
            UserDefaults.standard.set(symbols, forKey: "movementSymbols")
        }
        if let title = self.nationalHoliday.text {
            UserDefaults.standard.set(title, forKey: "nationalHoliday")
            self.viewController?.nationalHolidayCalendarName = title
        }
        let dateComponentsAllDay = Calendar.current.dateComponents(in: .current, from: self.dateAllDay.date)
        UserDefaults.standard.set(dateComponentsAllDay.hour, forKey: "dateAllDayH")
        UserDefaults.standard.set(dateComponentsAllDay.minute, forKey: "dateAllDayM")
        
        self.viewController!.updateDays()
        self.viewController!.pKCanvasView.becomeFirstResponder()
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
