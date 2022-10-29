//
//  APCDData.swift
//  APCDigital
//
//  Created by Shin Inaba on 2022/10/29.
//  Copyright © 2022 shi-n. All rights reserved.
//

import Foundation

class APCDData {
    static let instance = APCDData()
    
    var nationalHoliday = "日本の祝日"
    var movementSymbols = ""
    
    init() {
        if let title = UserDefaults.standard.string(forKey: "nationalHoliday") {
            self.nationalHoliday = title
        }
        print("nationalHoliday:\(nationalHoliday)")

        if let symbols = UserDefaults.standard.string(forKey: "movementSymbols") {
            self.movementSymbols = symbols
        }
        print("movementSymbols:\(movementSymbols)")
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
