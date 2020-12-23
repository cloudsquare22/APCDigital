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
        self.inkBlack.backgroundColor = .systemGray6
    }

    func loadNib(){
        let view = Bundle.main.loadNibNamed("PencilCaseView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
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
        self.pKCanvasView!.tool = PKInkingTool(.pen, color: .black, width: PKInkingTool.InkType.pen.defaultWidth)
        self.clearBackground()
        self.inkBlack.backgroundColor = .systemGray6
    }
    
    @IBAction func tapRed(_ sender: Any) {
        self.pKCanvasView!.tool = PKInkingTool(.pen, color: .red, width: PKInkingTool.InkType.pen.defaultWidth)
        self.clearBackground()
        self.inkRed.backgroundColor = .systemGray6
    }
    
    @IBAction func tapBlue(_ sender: Any) {
        self.pKCanvasView!.tool = PKInkingTool(.pen, color: .blue, width: PKInkingTool.InkType.pen.defaultWidth)
        self.clearBackground()
        self.inkBlue.backgroundColor = .systemGray6
    }
    
    @IBAction func tapGreen(_ sender: Any) {
        self.pKCanvasView!.tool = PKInkingTool(.pen, color: .green, width: PKInkingTool.InkType.pen.defaultWidth)
        self.clearBackground()
        self.inkGreen.backgroundColor = .systemGray6
    }
    
    @IBAction func tapOrange(_ sender: Any) {
        self.pKCanvasView!.tool = PKInkingTool(.pen, color: .orange, width: PKInkingTool.InkType.pen.defaultWidth)
        self.clearBackground()
        self.inkOrange.backgroundColor = .systemGray6
    }
    
    @IBAction func tapPurple(_ sender: Any) {
        self.pKCanvasView!.tool = PKInkingTool(.pen, color: .purple, width: PKInkingTool.InkType.pen.defaultWidth)
        self.clearBackground()
        self.inkPurple.backgroundColor = .systemGray6
    }
    
    @IBAction func tapMarkerYellow(_ sender: Any) {
        self.pKCanvasView!.tool = PKInkingTool(.marker, color: .yellow, width: PKInkingTool.InkType.marker.defaultWidth)
        self.clearBackground()
        self.inkMarkerYellow.backgroundColor = .systemGray6
    }
    
    @IBAction func tapErase(_ sender: Any) {
        self.pKCanvasView!.tool = PKEraserTool(.vector)
        self.clearBackground()
        self.inkErase.backgroundColor = .systemGray6
    }
    
}
