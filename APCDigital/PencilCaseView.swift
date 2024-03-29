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
    var pKCanvasView: RapPKCanvasView? = nil

    let pencilInteraction = UIPencilInteraction()
    
    enum Ink {
        case black
        case red
        case blue
        case green
        case orange
        case purple
        case brown
        case yellow
    }

    var selectInk: Ink = .black
    var saveInk: Ink = .black
    var onPencil = false
    var onMarker = false
    var onErase = false
    var onTaskbox = false

    @IBOutlet weak var inkBlack: UIButton!
    @IBOutlet weak var inkRed: UIButton!
    @IBOutlet weak var inkBlue: UIButton!
    @IBOutlet weak var inkGreen: UIButton!
    @IBOutlet weak var inkOrange: UIButton!
    @IBOutlet weak var inkPurple: UIButton!
    @IBOutlet weak var inkBrown: UIButton!
    @IBOutlet weak var inkYellow: UIButton!
    @IBOutlet weak var inkErase: UIButton!
    @IBOutlet weak var pencil: UIButton!
    @IBOutlet weak var marker: UIButton!
    @IBOutlet weak var ruler: UIButton!
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var taskbox: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    convenience init(frame: CGRect, pKCanvasView: RapPKCanvasView) {
        self.init(frame: frame)
        self.pKCanvasView = pKCanvasView
        self.pKCanvasView!.tool = PKInkingTool(.monoline, color: .black, width: PKInkingTool.InkType.monoline.minWidth())
        self.inkBlack.backgroundColor = .systemGray5
    }

    func loadNib(){
        let view = Bundle.main.loadNibNamed("PencilCaseView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.pencilInteraction.delegate = self
        view.addInteraction(self.pencilInteraction)
    }
    
    func inkBackground(ink: Ink) {
        self.inkBlack.backgroundColor = .clear
        self.inkRed.backgroundColor = .clear
        self.inkBlue.backgroundColor = .clear
        self.inkGreen.backgroundColor = .clear
        self.inkOrange.backgroundColor = .clear
        self.inkPurple.backgroundColor = .clear
        self.inkBrown.backgroundColor = .clear
        self.inkYellow.backgroundColor = .clear
        switch ink {
        case .black:
            self.inkBlack.backgroundColor = .systemGray5
        case .red:
            self.inkRed.backgroundColor = .systemGray5
        case .blue:
            self.inkBlue.backgroundColor = .systemGray5
        case .green:
            self.inkGreen.backgroundColor = .systemGray5
        case .orange:
            self.inkOrange.backgroundColor = .systemGray5
        case .purple:
            self.inkPurple.backgroundColor = .systemGray5
        case .brown:
            self.inkBrown.backgroundColor = .systemGray5
        case .yellow:
            self.inkYellow.backgroundColor = .systemGray5
        }
    }
    
    @IBAction func tapBlack(_ sender: Any) {
        self.inkBackground(ink: .black)
        self.updateInk(ink: .black)
    }
    
    @IBAction func tapRed(_ sender: Any) {
        self.inkBackground(ink: .red)
        self.updateInk(ink: .red)
    }
    
    @IBAction func tapBlue(_ sender: Any) {
        self.inkBackground(ink: .blue)
        self.updateInk(ink: .blue)
    }
    
    @IBAction func tapGreen(_ sender: Any) {
        self.inkBackground(ink: .green)
        self.updateInk(ink: .green)
    }
    
    @IBAction func tapOrange(_ sender: Any) {
        self.inkBackground(ink: .orange)
        self.updateInk(ink: .orange)
    }
    
    @IBAction func tapPurple(_ sender: Any) {
        self.inkBackground(ink: .purple)
        self.updateInk(ink: .purple)
    }
    
    @IBAction func tapBrown(_ sender: Any) {
        self.inkBackground(ink: .brown)
        self.updateInk(ink: .brown)
    }
    
    @IBAction func tapYellow(_ sender: Any) {
        self.inkBackground(ink: .yellow)
        self.updateInk(ink: .yellow)
    }
    
    @IBAction func tapErase(_ sender: Any) {
        self.onErase.toggle()
        let color: UIColor = self.onErase ? .blue : .black
        let colorBG: UIColor = self.onErase ? .systemGray5 : .clear
        self.inkErase.tintColor = color
        self.inkErase.backgroundColor = colorBG
        self.updateInk()
        if let pkcanvasview = self.pKCanvasView {
            pkcanvasview.onErase = self.onErase
        }
    }

    @IBAction func tapPencil(_ sender: Any) {
        self.onPencil.toggle()
        if self.onMarker == true {
            self.onMarker = false
            self.marker.tintColor = .black
            self.marker.backgroundColor = .clear
        }
        let color: UIColor = self.onPencil ? self.selectInkToUIColor() : .black
        let colorBG: UIColor = self.onPencil ? .systemGray5 : .clear
        self.pencil.tintColor = color
        self.pencil.backgroundColor = colorBG
        self.updateInk()
    }
    
    @IBAction func tapMarker(_ sender: Any) {
        self.onMarker.toggle()
        if self.onPencil == true {
            self.onPencil = false
            self.pencil.tintColor = .black
            self.pencil.backgroundColor = .clear
        }
        let color: UIColor = self.onMarker ? self.selectInkToUIColor() : .black
        let colorBG: UIColor = self.onMarker ? .systemGray5 : .clear
        self.marker.tintColor = color
        self.marker.backgroundColor = colorBG
        self.updateInk()
        if let pkcanvasview = self.pKCanvasView {
            pkcanvasview.onMarker = self.onMarker
        }
    }
    
    @IBAction func tapRuler(_ sender: Any) {
        self.pKCanvasView?.isRulerActive.toggle()
        let color: UIColor = self.pKCanvasView!.isRulerActive ? self.selectInkToUIColor() : .black
        self.ruler.tintColor = color
    }
    
    @IBAction func tapUndo(_ sender: Any) {
        if let undoManager = self.pKCanvasView?.undoManager {
            print("undo")
            undoManager.undo()
        }
    }

    @IBAction func tapTaskbox(_ sender: Any) {
        self.onTaskbox.toggle()
        let color: UIColor = self.onTaskbox ? self.selectInkToUIColor() : .black
        let colorBG: UIColor = self.onTaskbox ? .systemGray5 : .clear
        self.taskbox.tintColor = color
        self.taskbox.backgroundColor = colorBG
        if let pkcanvasview = self.pKCanvasView {
            pkcanvasview.onTaskbox = self.onTaskbox
            pkcanvasview.taskBoxColor = self.selectInkToUIColor()
        }
    }
    
    func updateInk(ink: Ink? = nil) {
        if let ink = ink {
            self.saveInk = self.selectInk
            self.selectInk = ink
        }
        if self.onErase == true {
            self.pKCanvasView!.tool = PKEraserTool(.vector)
        }
        else if self.onPencil == true {
            self.pencil.tintColor = self.selectInkToUIColor()
            self.pKCanvasView!.tool = PKInkingTool(.pencil, color: selectInkToUIColor(), width: PKInkingTool.InkType.pencil.minWidth())
        }
        else if self.onMarker == true {
            self.marker.tintColor = self.selectInkToUIColor()
            self.pKCanvasView!.tool = PKInkingTool(.pen, color: selectInkToUIColor(), width: PKInkingTool.InkType.pen.minWidth())
        }
        else {
            self.pKCanvasView!.tool = PKInkingTool(.monoline, color: selectInkToUIColor(), width: PKInkingTool.InkType.monoline.minWidth())
        }
        if self.onTaskbox == true {
            self.taskbox.tintColor = self.selectInkToUIColor()
            self.pKCanvasView!.taskBoxColor = selectInkToUIColor()
        }
    }
    
    func selectInkToUIColor() -> UIColor {
        var result: UIColor = .clear
        switch selectInk {
        case .black:
            result = .black
        case .red:
            result = .red
        case .blue:
            result = .blue
        case .green:
            result = .green
            if let green = UIColor(named: "Basic Color Green") {
                result = green
            }
        case .orange:
            result = .orange
        case .purple:
            result = .purple
        case .brown:
            result = .brown
        case .yellow:
            result = .yellow
       }
        return result
    }
}

extension PencilCaseView: UIPencilInteractionDelegate {
    func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        self.onErase.toggle()
        let color: UIColor = self.onErase ? .blue : .black
        let colorBG: UIColor = self.onErase ? .systemGray5 : .clear
        self.inkErase.tintColor = color
        self.inkErase.backgroundColor = colorBG
        self.updateInk()
        if let pkcanvasview = self.pKCanvasView {
            pkcanvasview.onErase = self.onErase
        }
    }
}

extension PKInkingTool.InkType {
    func minWidth() -> CGFloat {
        return self.validWidthRange.lowerBound
    }
}
