//
//  APCDCalendarUtil.swift
//  APCDigital
//
//  Created by Shin Inaba on 2022/01/02.
//  Copyright © 2022 shi-n. All rights reserved.
//

import Foundation
import UIKit
import Logging

class APCDCalendarUtil {
    let logger = Logger()
    
    static let instance = APCDCalendarUtil()

    func dispOutPeriod(label: UILabel, texts: [String]) {
        logger.debug("label: \(label) texts: \(texts)")
        label.text = ""
        if texts.isEmpty == false {
            label.isHidden = false
            let lineMax: Int = texts.count == 2 || texts.count == 3 ? 2 : 1
            var htmlText = ""
            for (index, schedule) in texts.indexed() {
                var appendText = texts.count > 1 ? self.abbreviationScheduleText(schedule, lineMax) : schedule
                appendText = appendText + (index + 1 != texts.count ? "<br>" : "")
                do {
                    let regex = try NSRegularExpression(pattern: "^([0-9]?[0-9]:[0-9][0-9])( .*)")
                    appendText = regex.stringByReplacingMatches(in: appendText,
                                                                options: [],
                                                                range: NSRange(location: 0, length: appendText.count),
                                                                withTemplate: "<font color=\"#008F00\">$1</font>$2")
                    print("regex.stringByReplacingMatches:\(appendText)")
                }
                catch {
                     print(error)
                }
                htmlText.append(contentsOf: appendText)
//                label.text?.append(contentsOf: appendText)
            }
            
            guard let data = htmlText.data(using: .utf8) else {
                return
            }
            do {
                let option: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
                let attrString = try NSMutableAttributedString(data: data, options: option, documentAttributes: nil)
                label.attributedText = attrString
                label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
                label.lineBreakMode = .byCharWrapping
            } catch {
                print(error.localizedDescription)
            }
            
            var fixedFrame = label.frame
            label.sizeToFit()
            fixedFrame.size.height = label.frame.size.height
            label.frame = fixedFrame
        }
        else {
            label.isHidden = true
        }
    }

    func abbreviationScheduleText(_ text: String, _ lineMax: Int = 1) -> String {
        var result = ""
        var lineCount = 1
        var lineSting = ""
        var limit = false
        var widthSum: CGFloat = 0.0
        let widthMax: CGFloat = 135.0

        let testLabel: UILabel = UILabel()
        testLabel.font = UIFont.systemFont(ofSize: 9.0, weight: .medium)
        
        print(text)
        for c in text {
            lineSting.append(c)

            testLabel.text = String(c)
            testLabel.sizeToFit()
            widthSum = widthSum + testLabel.frame.size.width
            print(testLabel.frame.size.width)
            
            if widthSum > widthMax {
                print("-----")
                print(widthSum)
                print("#####")
                widthSum = testLabel.frame.size.width
                lineSting.removeLast()
                result.append(lineSting)
                if lineCount < lineMax {
                    lineCount = lineCount + 1
                    lineSting = ""
                    lineSting.append(c)
                }
                else {
                    limit = true
                    break
                }
            }
        }
        if limit == false, lineCount <= lineMax {
            result.append(lineSting)
        }
        return result
    }
    
    func createMinuteSFSymbol(startDateComponents: DateComponents, startLineHidden: Bool) -> UIImage? {
        var minuteSFSymbol = "circle"
        switch startDateComponents.minute {
        case 0, 30:
            minuteSFSymbol = "circle"
        case 51, 52, 53, 54, 55, 56, 57, 58, 59:
            minuteSFSymbol = "circle"
        default:
            minuteSFSymbol = String(startDateComponents.minute!) + ".circle"
        }
        if startLineHidden == true {
            minuteSFSymbol = "arrowtriangle.down"
        }
        return UIImage(systemName: minuteSFSymbol)
    }
    
    func cgToUIColor(cgColor: CGColor, alpha: CGFloat) -> UIColor {
        return UIColor(red: cgColor.components![0],
                       green: cgColor.components![1],
                       blue: cgColor.components![2],
                       alpha: 0.3)
    }

}
