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
    var onErase: Bool = false
    var taskBoxColor: UIColor = .black

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("onTaskbox:\(onTaskbox), onErase:\(onErase)")
        guard self.onErase == false else {
            return
        }
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            print("touchesMoved: \(touch.precisePreviousLocation(in: self)) - \(touch.preciseLocation(in: self))")
//            self.strokeRectangle(location: touch.preciseLocation(in: self))
            let startPoint = PKStrokePoint(location: touch.precisePreviousLocation(in: self), timeOffset: 0, size: CGSize(width: 2.2, height: 2.2), opacity: 2, force: 1, azimuth: 1, altitude: 1)
            let endPoint = PKStrokePoint(location: touch.preciseLocation(in: self), timeOffset: 0, size: CGSize(width: 2.2, height: 2.2), opacity: 2, force: 1, azimuth: 1, altitude: 1)
            let ink = PKInk(.pen, color: .red)
            let path = PKStrokePath(controlPoints: [startPoint, endPoint], creationDate: Date())
            let stroke =  PKStroke(ink: ink, path: path)
//            self.drawing.strokes.append(stroke)
            print(self.drawing.strokes.count)
        }
    }

    func strokeRectangle(location: CGPoint) {
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
