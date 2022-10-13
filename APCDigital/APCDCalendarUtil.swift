//
//  APCDCalendarUtil.swift
//  APCDigital
//
//  Created by Shin Inaba on 2022/01/02.
//  Copyright © 2022 shi-n. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import Logging

class APCDCalendarUtil {
    let logger = Logger()
    
    static let instance = APCDCalendarUtil()

    func dispOutPeriod(label: UILabel, events: [EKEvent]) {
        logger.debug("label: \(label) events: \(events.count)")
        label.text = ""
        if events.isEmpty == false {
            label.isHidden = false
            let lineMax: Int = events.count == 2 || events.count == 3 ? 2 : 1
            var htmlText = ""
            for (index, event) in events.indexed() {
                let startDateComponents = Calendar.current.dateComponents(in: .current, from: event.startDate)
                if let startH = startDateComponents.hour, let startM = startDateComponents.minute {
                    var title = self.addLocationEventTitle(event: event)!
                    if event.isAllDay == false {
                        title = self.createOutScheduleString(startH: startH,
                                                             startM: startM,
                                                             title: title)
                    }
                    title = "●" + title
                    var appendText = events.count > 1 ? self.abbreviationScheduleText(title, lineMax) : title
                    appendText = appendText + (index + 1 != events.count ? "<br>" : "")
                    let rgb = event.calendar.cgColor.getRGBInt()
                    print("rgb:\(rgb)")
                    let colormark = String(format: "<font color=\"#%0X%0X%0X\">●</font>", rgb.0, rgb.1, rgb.2)
                    print("rgb:\(colormark)")
                    do {
                        if event.isAllDay == true {
                            let regex = try NSRegularExpression(pattern: "^(●)(.*)")
                            appendText = regex.stringByReplacingMatches(in: appendText,
                                                                        options: [],
                                                                        range: NSRange(location: 0, length: appendText.count),
                                                                        withTemplate: "\(colormark)$2")
                        }
                        else {
                            let regex = try NSRegularExpression(pattern: "^(●)([0-9]?[0-9]:[0-9][0-9])( .*)")
                            appendText = regex.stringByReplacingMatches(in: appendText,
                                                                        options: [],
                                                                        range: NSRange(location: 0, length: appendText.count),
                                                                        withTemplate: "\(colormark)<font color=\"#008F00\">$2</font>$3")
                        }
                        print("regex.stringByReplacingMatches:\(appendText)")
                    }
                    catch {
                         print(error)
                    }
                    htmlText.append(contentsOf: appendText)
                }
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

    func createOutScheduleString(startH: Int, startM: Int, title: String) -> String {
        let outSchedule = String(format: "%d:%02d ", startH, startM) + title
        return outSchedule
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
    
    func createScheduleView(title: String,
                            event: EKEvent,
                            startDate: Date,
                            endDate: Date,
                            startLineHidden: Bool,
                            endLineHidden: Bool,
                            movementSymmbolList: [String],
                            base: ViewController? = nil) -> ScheduleView {
        let startDateComponents = Calendar.current.dateComponents(in: .current, from: startDate)
        var x = 55.0
        var widthAdd = 0.0
        switch startDateComponents.weekday! {
        case 2:
            x = 55.0
        case 3:
            x = 55.0 + 148.0
        case 4:
            x = 55.0 + 148.0 * 2.0
        case 5:
            x = 55.0 + 148.0 * 3.0
            widthAdd = 3.5
        case 6:
            x = 55.0 + 73 + 148.0 * 4.0
        case 7:
            x = 55.0 + 73 + 148.0 * 5.0
        case 1:
            x = 55.0 + 73 + 148.0 * 6.0
            widthAdd = 3.5
        default:
            x = 0.0
        }
        var y: Double = 169.0 + 45.5 * Double(startDateComponents.hour! - 6)
        if let minutes = startDateComponents.minute {
            if minutes != 0 {
                y = y + 45.5 * (Double(minutes) / Double(60))
            }
        }
        let diff = endDate.timeIntervalSince(startDate) / 900
        let scheduleView = ScheduleView(frame: CGRect(x: x, y: y, width: 140.0 + widthAdd, height: 11.375 * diff))
        scheduleView.baseView.backgroundColor = APCDCalendarUtil.instance.cgToUIColor(cgColor: event.calendar.cgColor, alpha: 0.3)
        scheduleView.label.text = title
        let lines = Int(floor(diff))
        print("diff:\(diff) lines:\(lines)")
        scheduleView.label.numberOfLines = lines
        var labelFrame = scheduleView.label.frame
        scheduleView.label.sizeToFit()
        labelFrame.size.height = scheduleView.label.frame.size.height
        scheduleView.label.frame = labelFrame
        scheduleView.minute.image = APCDCalendarUtil.instance.createMinuteSFSymbol(startDateComponents: startDateComponents, startLineHidden: startLineHidden)
        scheduleView.endTime.frame = CGRect(x: -8.0, y: 11.375 * diff - 2, width: 16, height: 16)
        
        if movementSymmbolList.contains(String(title.prefix(1))) == true {
            scheduleView.addLine(isMove: true, isStartLineHidden: startLineHidden, isEndLineHidden: endLineHidden)
        }
        else {
            scheduleView.addLine(isMove: false, isStartLineHidden: startLineHidden, isEndLineHidden: endLineHidden)
        }
        
        if let base = base {
            base.scheduleViews.append((x: x, y: y, w: 140.0 + widthAdd, h: 11.375 * diff, event: event))
        }

        return scheduleView
    }
    
    func makeMovementSymmbolList() -> [String] {
        var movementSymmbolList: [String] = []
        if let symbols = UserDefaults.standard.string(forKey: "movementSymbols") {
            for symbol in symbols {
                movementSymmbolList.append(String(symbol))
            }
        }
        return movementSymmbolList
    }
    
    func addLocationEventTitle(event: EKEvent) -> String? {
        var result = event.title
        if let location = event.structuredLocation?.title, location.isEmpty == false {
            let locations = location.split(separator: "\n")
            result = String(format: "%@(%@)", event.title, String(locations[0]))
        }
        return result
    }

    func createDayoverTitle(title: String, endH: Int, endM :Int) -> String {
        return title + String(format: "\n〜%d:%02d", endH, endM)
    }
    
    func createDayoverEnd(startDateComponents: DateComponents) -> Date {
        var endDateComponents: DateComponents = startDateComponents
        endDateComponents.hour = 23
        endDateComponents.minute = 30
        return Calendar.current.date(from: endDateComponents)!
    }
    
    func isEventFilter(event: EKEvent) -> Bool {
        let eventFilters: [(calendar: String, filterString: String)] = EventFilter.selectAll()
        let isEventFilter = eventFilters.contains(where: { (calendar, filterString) in
            var result = false
            if event.calendar.title == calendar {
                if event.title.contains(filterString) == true {
                    result = true
                }
            }
            return result
        })
        return isEventFilter
    }
    
}
