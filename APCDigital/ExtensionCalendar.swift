//
//  ExtensionCalendar.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/11/05.
//  Copyright © 2020 shi-n. All rights reserved.
//

import Foundation

extension Calendar {
    static func monthSymbols(local: Locale) -> [String] {
        var calendar = Calendar.current
        calendar.locale = local
        return calendar.monthSymbols
    }

    static func standaloneMonthSymbols(local: Locale) -> [String] {
        var calendar = Calendar.current
        calendar.locale = local
        return calendar.standaloneMonthSymbols
    }

    static func shortMonthSymbols(local: Locale) -> [String] {
        var calendar = Calendar.current
        calendar.locale = local
        return calendar.shortMonthSymbols
    }

    static func shortStandaloneMonthSymbols(local: Locale) -> [String] {
        var calendar = Calendar.current
        calendar.locale = local
        return calendar.shortStandaloneMonthSymbols
    }
}
