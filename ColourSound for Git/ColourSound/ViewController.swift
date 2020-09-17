//
//  ViewController.swift
//  Relief
//
//  Created by Jowan Mead on 14/03/2020.
//  Copyright © 2020 Jowan Mead. All rights reserved.
//

import UIKit
import MaLiang
import AudioKit

class ViewController: UIViewController {
    
    @IBOutlet var canvas: Canvas!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var eraseButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var swatchButton: UIButton!
    
    var brushes: [Brush] = []
    
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    
    //For eraser functionality - Bool to check if erasing has been triggered, and UIColour to store the last colour used on the canvas when eraser is triggered.
    var erasing: Bool = false
    var lastCanvasColour: UIColor = .black
    
    var color: UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    private func
        registerBrush(with imageName: String) throws -> Brush {
        let texture = try
            canvas.makeTexture(with: UIImage(named: imageName)!.pngData()!)
        return try
            canvas.registerBrush(name: imageName, textureID: texture.id)
    }
    
    override func viewDidLoad() {
        canvas.setup()
        canvas.initialisePoints()
        canvas.initMusicPoints()
        super.viewDidLoad()
        registerBrushes()
        let index = 2
        let brush = brushes[index]
        brush.color = .charcoalGrey
        brush.use()
        //Add observer for actual colour.
        NotificationCenter.default.addObserver(self, selector: #selector(didGetNotification(_:)), name: Notification.Name("colour"), object: nil)
        //Add observer for colour genre.
        NotificationCenter.default.addObserver(self, selector: #selector(didGetGenreNotification(_:)), name: Notification.Name("genre"), object: nil)
    }
    
    //Upon getting a notification from the colour swatch, changes the colour of the current brush to that of the button pressed.
    @objc func didGetNotification(_ notification: Notification) {
        let colour = notification.object as! UIColor
        let brush = brushes[2]
        brush.color = colour
        brush.use()
    }
    //Upon getting a notification from the colour swatch, changes the Canvas' colour genre to that of the button pressed.
    @objc func didGetGenreNotification(_ notification: Notification) {
        let genre = notification.object as! UIColor
        canvas.currentColour = genre
    }
    
    func registerBrushes() {
        do {
            let pen = canvas.defaultBrush!
            pen.name = "Pen"
            pen.opacity = 0.1
            pen.pointSize = 5
            pen.pointStep = 0.5
            pen.color = color
            
            let pencil = try! registerBrush(with: "pencil")
            pencil.rotation = .random
            pencil.pointSize = 3
            pencil.pointStep = 2
            pencil.forceSensitive = 0.3
            pencil.opacity = 1
            
            let brush = try! registerBrush(with: "brush")
            brush.rotation = .ahead
            brush.pointSize = 15
            brush.pointStep = 2
            brush.forceSensitive = 1
            brush.color = color
            brush.forceOnTap = 0.5
            
            let texture = try! canvas.makeTexture(with: UIImage (named: "glow")!.pngData()!)
            let glow: GlowingBrush = try! canvas.registerBrush(name: "glow", textureID: texture.id)
            glow.opacity = 0.05
            glow.coreProportion = 0.2
            glow.pointSize = 20
            glow.rotation = .ahead
            
            let claw = try! registerBrush(with: "claw")
            claw.rotation = .ahead
            claw.pointSize = 30
            claw.pointStep = 5
            claw.forceSensitive = 1
            claw.color = color
            
            let eraser = try! canvas.registerBrush(name: "Eraser") as Eraser
            eraser.forceSensitive = 1.3
            
            brushes = [pen, pencil, brush, claw, eraser]
            
        }
    }
    
    func triggerErase() {
        let brush = brushes[4]
        brush.use()
    }
    
    //Trigger Canvas undo function
    @IBAction func undoAction(_ sender: Any) {
        canvas.undo()
    }
    //Trigger Canvas redo function
    @IBAction func redoAction(_ sender: Any) {
        canvas.redo()
    }
    
    @IBAction func eraseAction(_ sender: Any) {
        if erasing == false {
            erasing = true
            triggerErase()
            eraseButton.setImage(UIImage(systemName: "paintbrush.fill"), for: .normal)
            lastCanvasColour = canvas.currentColour
            canvas.currentColour = .clear
        }
        else {
            erasing = false
            canvas.currentColour = lastCanvasColour
            let brush = brushes[2]
            brush.use()
            eraseButton.setImage(UIImage(systemName: "timelapse"), for: .normal)
        }
    }
    
    //Clear the canvas of drawing and clear the canvas' data.
    @IBAction func clearCanvas(_ sender: Any) {
        canvas.clear()
        canvas.clearArrays()
    }
    
    //Enable the colour swatch view.
    @IBAction func showSwatch(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "swatch_vc") as! SwatchViewController? else {
                return
        }
        present(vc, animated: true)
    }
}


