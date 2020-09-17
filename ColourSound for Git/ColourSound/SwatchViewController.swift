//
//  SwatchViewController.swift
//  Relief
//
//  Created by Jowan Mead on 22/04/2020.
//  Copyright © 2020 Jowan Mead. All rights reserved.
//

import UIKit

//Extend standard UIColor framework to include new shades.
extension UIColor {
    public class var charcoalGrey: UIColor {
        return UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
    }
    public class var hughesGrey: UIColor {
        return UIColor(red: 61/255, green: 61/255, blue: 61/255, alpha: 1)
    }
    public class var slateGrey: UIColor {
        return UIColor(red: 40/255, green: 64/255, blue: 64/255, alpha: 1)
    }
    public class var smokeGrey: UIColor {
        return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    public class var crimsonRed: UIColor {
        return UIColor(red: 222/255, green: 15/255, blue: 9/255, alpha: 1)
    }
    public class var carmineRed: UIColor {
        return UIColor(red: 138/255, green: 4/255, blue: 26/255, alpha: 1)
    }
    public class var tangerineRed: UIColor {
        return UIColor(red: 255/255, green: 105/255, blue: 5/255, alpha: 1)
    }
    public class var mahoganyRed: UIColor {
        return UIColor(red: 66/255, green: 13/255, blue: 9/255, alpha: 1)
    }
    public class var amberYellow: UIColor {
        return UIColor(red: 255/255, green: 191/255, blue: 0/255, alpha: 1)
    }
    public class var peachYellow: UIColor {
        return UIColor(red: 240/255, green: 149/255, blue: 42/255, alpha: 1)
    }
    public class var dijonYellow: UIColor {
        return UIColor(red: 196/255, green: 145/255, blue: 2/255, alpha: 1)
    }
    public class var lemonYellow: UIColor {
        return UIColor(red: 239/255, green: 253/255, blue: 95/255, alpha: 1)
    }
    public class var forestGreen: UIColor {
        return UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
    }
    public class var limeGreen: UIColor {
        return UIColor(red: 199/255, green: 234/255, blue: 70/255, alpha: 1)
    }
    public class var kellyGreen: UIColor {
        return UIColor(red: 76/255, green: 187/255, blue: 23/255, alpha: 1)
    }
    public class var emeraldGreen: UIColor {
        return UIColor(red: 80/255, green: 220/255, blue: 110/255, alpha: 1)
    }
    public class var royalBlue: UIColor {
        return UIColor(red: 17/255, green: 30/255, blue: 108/255, alpha: 1)
    }
    public class var tealBlue: UIColor {
        return UIColor(red: 0/255, green: 128/255, blue: 129/255, alpha: 1)
    }
    public class var egyptianBlue: UIColor {
        return UIColor(red: 16/255, green: 52/255, blue: 166/255, alpha: 1)
    }
    public class var azureBlue: UIColor {
        return UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
    }
    public class var flamingoPink: UIColor {
        return UIColor(red: 252/255, green: 163/255, blue: 183/255, alpha: 1)
    }
    public class var cerisePink: UIColor {
        return UIColor(red: 222/255, green: 49/255, blue: 99/255, alpha: 1)
    }
    public class var grimacePurple: UIColor {
        return UIColor(red: 110/255, green: 8/255, blue: 108/255, alpha: 1)
    }
    public class var violetPurple: UIColor {
        return UIColor(red: 84/255, green: 36/255, blue: 189/255, alpha: 1)
    }
}

//View for picking colours to paint with.
class SwatchViewController: UIViewController {
    //associate colours with objects to be passed back to canvas view
    public var charcoal: UIColor = .charcoalGrey
    public var hughes: UIColor = .hughesGrey
    public var slate: UIColor = .slateGrey
    public var smoke: UIColor = .smokeGrey
    public var crimson: UIColor = .crimsonRed
    public var carmine: UIColor = .carmineRed
    public var tangerine: UIColor = .tangerineRed
    public var mahogany: UIColor = .mahoganyRed
    public var amber: UIColor = .amberYellow
    public var peach: UIColor = .peachYellow
    public var dijon: UIColor = .dijonYellow
    public var lemon: UIColor = .lemonYellow
    public var forest: UIColor = .forestGreen
    public var lime: UIColor = .limeGreen
    public var kelly: UIColor = .kellyGreen
    public var emerald: UIColor = .emeraldGreen
    public var royal: UIColor = .royalBlue
    public var teal: UIColor = .tealBlue
    public var egyptian: UIColor = .egyptianBlue
    public var azure: UIColor = .azureBlue
    public var flamingo: UIColor = .flamingoPink
    public var cerise: UIColor = .cerisePink
    public var grimace: UIColor = .grimacePurple
    public var violet: UIColor = .violetPurple
    
    //Create objects for the 6 colour categories to be passed back to the Canvas.
    public var red: UIColor = .red
    public var yellow: UIColor = .yellow
    public var blue: UIColor = .blue
    public var green: UIColor = .green
    public var purple: UIColor = .purple
    public var black: UIColor = .black
    
    //Declaration of buttons on swatch.
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var charcoalButton: UIButton!
    @IBOutlet weak var hughesButton: UIButton!
    @IBOutlet weak var slateButton: UIButton!
    @IBOutlet weak var smokeButton: UIButton!
    @IBOutlet weak var crimsonButton: UIButton!
    @IBOutlet weak var carmineButton: UIButton!
    @IBOutlet weak var mahoganyButton: UIButton!
    @IBOutlet weak var tangerineButton: UIButton!
    @IBOutlet weak var amberButton: UIButton!
    @IBOutlet weak var dijonButton: UIButton!
    @IBOutlet weak var peachButton: UIButton!
    @IBOutlet weak var lemonButton: UIButton!
    @IBOutlet weak var forestButton: UIButton!
    @IBOutlet weak var limeButton: UIButton!
    @IBOutlet weak var kellyButton: UIButton!
    @IBOutlet weak var emeraldButton: UIButton!
    @IBOutlet weak var royalButton: UIButton!
    @IBOutlet weak var tealButton: UIButton!
    @IBOutlet weak var egyptianButton: UIButton!
    @IBOutlet weak var azureButton: UIButton!
    @IBOutlet weak var flamingoButton: UIButton!
    @IBOutlet weak var ceriseButton: UIButton!
    @IBOutlet weak var grimaceButton: UIButton!
    @IBOutlet weak var violetButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //Function to return to main canvas view when return chevron is pressed.
    @IBAction func returnCanvas(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    //Connect buttons to colour notification sends, communicating colour choices back to the canvas when the related button is pressed.
    @IBAction func charcoalTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: charcoal)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: black)
    }
    
    @IBAction func hughesTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: hughes)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: black)
    }
    @IBAction func slateTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: slate)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: black)
    }
    @IBAction func smokeTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: smoke)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: black)
    }
    @IBAction func crimsonTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: crimson)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: red)
    }
    
    @IBAction func carmineTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: carmine)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: red)
    }
    @IBAction func mahoganyTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: mahogany)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: red)
    }
    @IBAction func tangerineTouched(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("colour"), object: tangerine)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: red)
    }
    @IBAction func amberTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: amber)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: yellow)
    }
    @IBAction func dijonTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: dijon)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: yellow)
    }
    @IBAction func peachTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: peach)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: yellow)
    }
    @IBAction func lemonTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: lemon)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: yellow)
    }
    @IBAction func forestTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: forest)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: green)
    }
    @IBAction func limeTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: lime)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: green)
    }
    @IBAction func kellyTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: kelly)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: green)
    }
    @IBAction func emeraldTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: emerald)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: green)
    }
    @IBAction func royalTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: royal)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: blue)
    }
    @IBAction func tealTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: teal)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: blue)
    }
    @IBAction func egyptianTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: egyptian)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: blue)
    }
    @IBAction func azureTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: azure)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: blue)
    }
    @IBAction func flamingoTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: flamingo)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: purple)
    }
    @IBAction func ceriseTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: cerise)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: purple)
    }
    @IBAction func grimaceTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: grimace)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: purple)
    }
    @IBAction func violetTouched(_ sender: Any){
        NotificationCenter.default.post(name: Notification.Name("colour"), object: violet)
        NotificationCenter.default.post(name: Notification.Name("genre"), object: purple)
    }    
}
