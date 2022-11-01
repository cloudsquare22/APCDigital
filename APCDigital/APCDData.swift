//
//  APCDData.swift
//  APCDigital
//
//  Created by Shin Inaba on 2022/10/29.
//  Copyright © 2022 shi-n. All rights reserved.
//

import Foundation
import EventKit

class APCDData {
    static let instance = APCDData()

    var eventStore = EKEventStore()

    var calendars: [EKCalendar] = []
    var displayCalendars: [String] = []
    var displayOutCalendars: [String] = []
    var nationalHoliday = "日本の祝日"
    var movementSymbols = ""
    
    init() {
    }

    func loadData() {
        if let title = UserDefaults.standard.string(forKey: "nationalHoliday") {
            self.nationalHoliday = title
        }
        print("nationalHoliday:\(nationalHoliday)")

        if let symbols = UserDefaults.standard.string(forKey: "movementSymbols") {
            self.movementSymbols = symbols
        }
        print("movementSymbols:\(movementSymbols)")

        self.updateCalendars()
    }
    
    func description() -> String {
        "APCDData description"
    }

    func updateCalendars() {
        let calendarAll = eventStore.calendars(for: .event)
        self.calendars = []
        for calendar in calendarAll {
            switch calendar.type {
            case .local, .calDAV,
                    .subscription where calendar.title != APCDData.instance.nationalHoliday:
                self.calendars.append(calendar)
            default:
                break
            }
        }
        self.calendars.sort() {
            $0.title < $1.title
        }
        
        if let displays = UserDefaults.standard.stringArray(forKey: "displayCalendars") {
            self.displayCalendars = displays
        }
        else {
            for calendar in self.calendars {
                self.displayCalendars.append(calendar.title)
            }
        }

        if let displays = UserDefaults.standard.stringArray(forKey: "displayOutCalendars") {
            self.displayOutCalendars = displays
        }
    }

    func setNationalHoliday(nationalHoliday: String) {
        UserDefaults.standard.set(nationalHoliday, forKey: "nationalHoliday")
        self.nationalHoliday = nationalHoliday
    }
    
    func setMovementSymbols(movementSymbols: String) {
        UserDefaults.standard.set(movementSymbols, forKey: "movementSymbols")
        self.movementSymbols = movementSymbols
    }
}
