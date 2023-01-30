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
    enum DType {
        case ipad_12_9_more_space
        case etc
    }
    static func getDevie() -> DType {
        print("Device:\(UIScreen.main.bounds.size)")
        var dtype: DType = .etc
        switch UIScreen.main.bounds.size.width {
        case 1590.0:
            print("iPad Pro 12.9inch スペースを拡大")
            dtype = .ipad_12_9_more_space
        case 1366.0:
            print("iPad Pro 12.9inch デフォルト")
        case 1024.0:
            print("iPad mini")
        default:
            print("???")
        }
        return dtype
    }
}
