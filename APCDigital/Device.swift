//
//  Device.swift
//  APCDigital
//
//  Created by Shin Inaba on 2021/07/20.
//  Copyright © 2021 shi-n. All rights reserved.
//

import Foundation
import UIKit

class Device {
    static func getDevie() {
        print("Device:\(UIScreen.main.bounds.size)")
        switch UIScreen.main.bounds.size.width {
        case 1366.0:
            print("iPad Pro 12.9inch")
        case 1024.0:
            print("iPad mini")
        default:
            print("???")
        }
    }
}
