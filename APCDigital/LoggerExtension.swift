//
//  LoggerExtension.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/09/26.
//  Copyright © 2020 shi-n. All rights reserved.
//

import Logging

extension Logger {
    static var level = Logger.Level.info
    
    init(function: String = #function) {
        self.init(label: function)
        self.logLevel = Logger.level
    }
    
    func info(_ message: String = "" , function: String = #function, line: Int = #line) {
        self.info(Logger.Message(stringLiteral: String("[\(function):\(line)] \(message)")))
    }

    func debug(_ message: String = "" , function: String = #function, line: Int = #line) {
        self.debug(Logger.Message(stringLiteral: String("[\(function):\(line)] \(message)")))
    }
}
