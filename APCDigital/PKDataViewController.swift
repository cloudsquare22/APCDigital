//
//  PKDataViewController.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/10.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class PKDataViewController: UITableViewController {
    
    var pages: [(year: Int , week: Int)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pages = Pages.selectAll()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Pages(Pecil Kit Data)"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pages.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pkdata", for: indexPath) as! PKDataViewCell
        cell.yearWeek.text = String(format: "%04d年 - %02d週", pages[indexPath.row].year, pages[indexPath.row].week)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete")
            Pages.delete(year: self.pages[indexPath.row].year, week: self.pages[indexPath.row].week)
            self.pages = Pages.selectAll()
        }
        self.tableView.reloadData()
    }

}
