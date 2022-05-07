//
//  RapPKCanvasView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2021/09/18.
//  Copyright © 2021 shi-n. All rights reserved.
//

import UIKit
import PencilKit

class RapPKCanvasView: PKCanvasView {
    
    var onTaskbox: Bool = false
    var taskBoxColor: UIColor = .black

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.onTaskbox == true else {
            return
        }
        print(#function)
        let touch = touches.first
        if let location = touch?.location(in: self), let type = touch?.type {
            print("type:\(type)")
            print("x:\(location.x) y:\(location.y)")
            if type == .pencil {
                self.strokeRectangle(location: location)
            }
        }
    }

    func strokeRectangle(location: CGPoint) {
//        let pointArrays = [
//            [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 100), CGPoint(x: 200, y: 200), CGPoint(x: 100, y: 200), CGPoint(x: 100, y: 100)],
//        ]
        let size: CGFloat = 8
        let x = location.x - (size / 2)
        let y = location.y - (size / 2)
        let pointArrays = [
            [CGPoint(x: x, y: y),
             CGPoint(x: x + size, y: y),
             CGPoint(x: x + size, y: y + size),
             CGPoint(x: x, y: y + size),
             CGPoint(x: x, y: y)],
        ]
        let ink = PKInk(.pen, color: self.taskBoxColor)
        var strokes: [PKStroke] = []

        for points in pointArrays where points.count > 1 {
            let strokePoints = points.enumerated().map { index, point in
                PKStrokePoint(location: point, timeOffset: 0.1 * TimeInterval(index), size: CGSize(width: 2.6, height: 2.6), opacity: 2, force: 1, azimuth: 0, altitude: 0)
            }

            var startStrokePoint = strokePoints.first!

            for strokePoint in strokePoints {
                let path = PKStrokePath(controlPoints: [startStrokePoint, strokePoint], creationDate: Date())
                strokes.append(PKStroke(ink: ink, path: path))
                startStrokePoint = strokePoint
            }
        }
        print("strokes:\(strokes.count)")
        self.drawing.strokes.append(contentsOf: strokes)
        
        self.undoManager!.registerUndo(withTarget: self, selector: #selector(undoStrocke), object: self.drawing.strokes)
    }
    
    @objc func undoStrocke() {
        for _ in 1...5 {
            self.drawing.strokes.removeLast()
        }
    }
    
}
