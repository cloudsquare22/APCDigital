//
//  Calendar.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/08/08.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit

class APCDCalendar {
    func export() -> URL? {
        var result: URL? = nil
        
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0))
        let templateView = UIImageView(image: UIImage(named: "aptemplate"))
        templateView.frame = CGRect(x: 0.0, y: 0.0, width: 1366.0, height: 1024.0)
        templateView.contentMode = .scaleAspectFit
        view.addSubview(templateView)
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil)
        UIGraphicsBeginPDFPage()
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return result}
        view.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
            
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + "APCDigital_ec.pdf"
            pdfData.write(toFile: documentsFileName, atomically: true)
            result = URL(fileURLWithPath: documentsFileName)
        }
        return result
    }
}
