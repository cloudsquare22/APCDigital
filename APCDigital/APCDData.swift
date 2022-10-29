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
    
    init() {
        if let title = UserDefaults.standard.string(forKey: "nationalHoliday") {
            nationalHoliday = title
        }
        print("nationalHoliday:\(nationalHoliday)")
    }
    
    func setNationalHoliday(nationalHoliday: String) {
        UserDefaults.standard.set(nationalHoliday, forKey: "nationalHoliday")
        self.nationalHoliday = nationalHoliday
    }
}
