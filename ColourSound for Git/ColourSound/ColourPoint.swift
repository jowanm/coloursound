//
//  ColourPoint.swift
//  MaLiang
//
//  Created by Jowan Mead on 07/05/2020.
//

import UIKit
//ColourSound structure to keep track of each colour's score, and store its relative musical interval.
struct ColourPoint {
    //Colour's score, AKA how much is painted onto the screen
    var score: Int = 0
    //Colour itself
    var colour: UIColor
    //Colour's relative interval, used to access the equivalent index in the MIDI modeArray.
    var note: Int = 0
}
