//
//  PencilCaseView.swift
//  APCDigital
//
//  Created by Shin Inaba on 2020/12/23.
//  Copyright © 2020 shi-n. All rights reserved.
//

import UIKit
import PencilKit

class PencilCaseView: UIView {
    var pKCanvasView: PKCanvasView? = nil

    let pencilInteraction = UIPencilInteraction()
    
    enum Ink {
        case black
        case red
        case blue
        case green
        case orange
        case purple
        case markerYellow
        case erase
    }
    var selectInk: Ink = .black
    var saveInk: Ink = .black

    @IBOutlet weak var inkBlack: UIButton!
    @IBOutlet weak var inkRed: UIButton!
    @IBOutlet weak var inkBlue: UIButton!
    @IBOutlet weak var inkGreen: UIButton!
    @IBOutlet weak var inkOrange: UIButton!
    @IBOutlet weak var inkPurple: UIButton!
    @IBOutlet weak var inkMarkerYellow: UIButton!
    @IBOutlet weak var inkErase: UIButton!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    convenience init(frame: CGRect, pKCanvasView: PKCanvasView) {
        self.init(frame: frame)
        self.pKCanvasView = pKCanvasView
        self.pKCanvasView!.tool = PKInkingTool(.pen, color: .black, width: PKInkingTool.InkType.pen.defaultWidth)
        self.inkBlack.backgroundColor = .systemGray5
    }

    func loadNib(){
        let view = Bundle.main.loadNibNamed("PencilCaseView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.pencilInteraction.delegate = self
        view.addInteraction(self.pencilInteraction)
    }
    
    func clearBackground() {
        self.inkBlack.backgroundColor = .clear
        self.inkRed.backgroundColor = .clear
        self.inkBlue.backgroundColor = .clear
        self.inkGreen.backgroundColor = .clear
        self.inkOrange.backgroundColor = .clear
        self.inkPurple.backgroundColor = .clear
        self.inkMarkerYellow.backgroundColor = .clear
        self.inkErase.backgroundColor = .clear
    }
    
    @IBAction func tapBlack(_ sender: Any) {
        self.updateInk(ink: .black)
    }
    
    @IBAction func tapRed(_ sender: Any) {
        self.updateInk(ink: .red)
    }
    
    @IBAction func tapBlue(_ sender: Any) {
        self.updateInk(ink: .blue)
    }
    
    @IBAction func tapGreen(_ sender: Any) {
        self.updateInk(ink: .green)
    }
    
    @IBAction func tapOrange(_ sender: Any) {
        self.updateInk(ink: .orange)
    }
    
    @IBAction func tapPurple(_ sender: Any) {
        self.updateInk(ink: .purple)
    }
    
    @IBAction func tapMarkerYellow(_ sender: Any) {
        self.updateInk(ink: .markerYellow)
    }
    
    @IBAction func tapErase(_ sender: Any) {
        self.updateInk(ink: .erase)
    }
    
    func updateInk(ink: Ink) {
        self.saveInk = self.selectInk
        self.selectInk = ink
        self.clearBackground()
        switch ink {
        case .black:
            self.pKCanvasView!.tool = PKInkingTool(.pen, color: .black, width: PKInkingTool.InkType.pen.defaultWidth)
            self.inkBlack.backgroundColor = .systemGray5
        case .red:
            self.pKCanvasView!.tool = PKInkingTool(.pen, color: .red, width: PKInkingTool.InkType.pen.defaultWidth)
            self.inkRed.backgroundColor = .systemGray5
        case .blue:
            self.pKCanvasView!.tool = PKInkingTool(.pen, color: .blue, width: PKInkingTool.InkType.pen.defaultWidth)
            self.inkBlue.backgroundColor = .systemGray5
        case .green:
            self.pKCanvasView!.tool = PKInkingTool(.pen, color: .green, width: PKInkingTool.InkType.pen.defaultWidth)
            self.inkGreen.backgroundColor = .systemGray5
        case .orange:
            self.pKCanvasView!.tool = PKInkingTool(.pen, color: .orange, width: PKInkingTool.InkType.pen.defaultWidth)
            self.inkOrange.backgroundColor = .systemGray5
        case .purple:
            self.pKCanvasView!.tool = PKInkingTool(.pen, color: .purple, width: PKInkingTool.InkType.pen.defaultWidth)
            self.inkPurple.backgroundColor = .systemGray5
        case .markerYellow:
            self.pKCanvasView!.tool = PKInkingTool(.marker, color: .yellow, width: PKInkingTool.InkType.marker.defaultWidth)
            self.inkMarkerYellow.backgroundColor = .systemGray5
        case .erase:
            self.pKCanvasView!.tool = PKEraserTool(.vector)
            self.inkErase.backgroundColor = .systemGray5
        }
    }
    
}

extension PencilCaseView: UIPencilInteractionDelegate {
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        if self.selectInk != .erase {
            self.updateInk(ink: .erase)
        }
        else {
            self.updateInk(ink: self.saveInk)
        }
    }
    
}
