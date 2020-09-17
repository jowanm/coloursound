//
//  Canvas.swift
//  MaLiang
//
//  Created by Harley.xk on 2018/4/11.
//

import UIKit
import AudioKit

open class Canvas: MetalView {
    
    //Please note - this class is an extended version of MaLiang's standard canvas class. Code added for the purpose of this project is marked with "ColourSound".
    
    
    //ColourSound - Array to store trigger points on the canvas.
    var canvasPoints: [CanvasPoint] = []
    //ColourSound - Variable to store the current colour being used.
    open var currentColour: UIColor = .black
    
    //ColourSound - Array to store scores of different colours.
    var colourPoints: [ColourPoint] = []
    
    //ColourSound - Array to track colours used in size order.
    var musicPoints: [ColourPoint] = []
    
    //ColourSound - name variable for checking current mode of music.
    var mode: String = "Ionian"
    
    //ColourSound - arrays to store MIDI notes of different modal scales.
    var modeArray: [MIDINoteNumber] = [0, 0, 0, 0, 0, 0, 0]
    var lastModeArray: [MIDINoteNumber] = [0, 0, 0, 0, 0, 0]
    
    //ColourSound - instruments used in audio implementation.
    var rootOsc = AKFMOscillatorFilterSynth()
    var synthOsc = AKFMOscillatorFilterSynth()
    var pianoOsc = AKRhodesPiano()
    var clarinetOsc = AKClarinet()
    var fluteOsc = AKFlute()
    //ColourSound - variable to track number of colours on the screen.
    var activeColours: Int = 0
    
    // MARK: - Brushes
    
    /// default round point brush, will not show in registeredBrushes
    open var defaultBrush: Brush!
    
    /// printer to print image textures on canvas
    open private(set) var printer: Printer!
    
    /// the actural size of canvas in points, may larger than current bounds
    /// size must between bounds size and 5120x5120
    open var size: CGSize {
        return drawableSize / contentScaleFactor
    }
    
    // delegate & observers
    
    open weak var renderingDelegate: RenderingDelegate?
    
    internal var actionObservers = ActionObserverPool()
    
    // add an observer to observe data changes, observers are not retained
    open func addObserver(_ observer: ActionObserver) {
        // pure nil objects
        actionObservers.clean()
        actionObservers.addObserver(observer)
    }
    
    /// Register a brush with image data
    ///
    /// - Parameter texture: texture data of brush
    /// - Returns: registered brush
    @discardableResult open func registerBrush<T: Brush>(name: String? = nil, from data: Data) throws -> T {
        let texture = try makeTexture(with: data)
        let brush = T(name: name, textureID: texture.id, target: self)
        registeredBrushes.append(brush)
        return brush
    }
    
    /// Register a brush with image data
    ///
    /// - Parameter file: texture file of brush
    /// - Returns: registered brush
    @discardableResult open func registerBrush<T: Brush>(name: String? = nil, from file: URL) throws -> T {
        let data = try Data(contentsOf: file)
        return try registerBrush(name: name, from: data)
    }
    
    /// Register a new brush with texture already registered on this canvas
    ///
    /// - Parameter textureID: id of a texture, default round texture will be used if sets to nil or texture id not found
    open func registerBrush<T: Brush>(name: String? = nil, textureID: String? = nil) throws -> T {
        let brush = T(name: name, textureID: textureID, target: self)
        registeredBrushes.append(brush)
        return brush
    }
    
    /// current brush used to draw
    /// only registered brushed can be set to current
    /// get a brush from registeredBrushes and call it's use() method to make it current
    open internal(set) var currentBrush: Brush!
    
    /// All registered brushes
    open private(set) var registeredBrushes: [Brush] = []
    
    /// find a brush by name
    /// nill will be retured if brush of name provided not exists
    open func findBrushBy(name: String?) -> Brush? {
        return registeredBrushes.first { $0.name == name }
    }
    
    /// All textures created by this canvas
    open private(set) var textures: [MLTexture] = []
    
    /// make texture and cache it with ID
    ///
    /// - Parameters:
    ///   - data: image data of texture
    ///   - id: id of texture, will be generated if not provided
    /// - Returns: created texture, if the id provided is already exists, the existing texture will be returend
    @discardableResult
    override open func makeTexture(with data: Data, id: String? = nil) throws -> MLTexture {
        // if id is set, make sure this id is not already exists
        if let id = id, let exists = findTexture(by: id) {
            return exists
        }
        let texture = try super.makeTexture(with: data, id: id)
        textures.append(texture)
        return texture
    }
    
    /// find texture by textureID
    open func findTexture(by id: String) -> MLTexture? {
        return textures.first { $0.id == id }
    }
    
    @available(*, deprecated, message: "this property will be removed soon, set the property forceSensitive on brush to 0 instead, changing this value will cause no affects")
    open var forceEnabled: Bool = true
    
    // MARK: - Zoom and scale
    /// the scale level of view, all things scales
    open var scale: CGFloat {
        get {
            return screenTarget?.scale ?? 1
        }
        set {
            screenTarget?.scale = newValue
        }
    }
    
    /// the zoom level of render target, only scale render target
    open var zoom: CGFloat {
        get {
            return screenTarget?.zoom ?? 1
        }
        set {
            screenTarget?.zoom = newValue
        }
    }
    
    /// the offset of render target with zoomed size
    open var contentOffset: CGPoint {
        get {
            return screenTarget?.contentOffset ?? .zero
        }
        set {
            screenTarget?.contentOffset = newValue
        }
    }
    
    // setup gestures
    open var paintingGesture: PaintingGestureRecognizer?
    open var tapGesture: UITapGestureRecognizer?
    
    /// this will setup the canvas and gestures、default brushs
    open override func setup() {
        super.setup()
        
        /// initialize default brush
        defaultBrush = Brush(name: "maliang.default", textureID: nil, target: self)
        currentBrush = defaultBrush
        
        /// initialize printer
        printer = Printer(name: "maliang.printer", textureID: nil, target: self)
        
        data = CanvasData()
    }
    
    /// take a snapshot on current canvas and export an image
    open func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, contentScaleFactor)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// clear all things on the canvas
    ///
    /// - Parameter display: redraw the canvas if this sets to true
    open override func clear(display: Bool = true) {
        super.clear(display: display)
        
        if display {
            data.appendClearAction()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    //ColourSound - fills the array of trigger points with canvasPoint objects, and the array of colours with different colours.
    public func initialisePoints() { // Divides the canvas into evenly spaced points on the x-axis and y-axis. Adds a point to array of triggers for each coordinate.
        for i in stride(from: 0, to: 373, by: 5) {
            for j in stride(from: 0, to: 568, by: 8){
                canvasPoints.append(CanvasPoint.init(point:CGPoint.init(x:i, y:j), colour: .clear))
            }
        }
        
        //ColourSound - Appends colours onto colour array with associated note intervals (5th is a '4' here due to index rules, etc.)
        colourPoints.append(ColourPoint.init(colour: .red, note: 4))
        colourPoints.append(ColourPoint.init(colour: .yellow, note: 2))
        colourPoints.append(ColourPoint.init(colour: .blue, note: 3))
        colourPoints.append(ColourPoint.init(colour: .green, note: 6))
        colourPoints.append(ColourPoint.init(colour: .purple, note: 5))
        colourPoints.append(ColourPoint.init(colour: .black, note: 1))
    }
    
    //ColourSound - fucntion to initialise the music points array.
    public func initMusicPoints()
    {
        for _ in 0...5 {
            musicPoints.append(ColourPoint.init(colour: .clear))
        }
    }
    
    //ColourSound - Takes a UIColour as input and checks it against the colour array to find that colour's index.
    public func colourCheck(colour: UIColor) -> Int {
        for i in 0...5 {
            if colourPoints[i].colour == colour {
                return i
            }
        }
        return 6 //dead case
    }
    
    //ColourSound - function to wipe score from array of colours and reset all trigger points to clear, the default colour.
    public func clearArrays() {
        for i in 0...5 {
            colourPoints[i].score = 0
        }
        for j in 0...canvasPoints.endIndex - 1 {
            canvasPoints[j].colour = .clear
        }
        for i in 0...5 {
            musicPoints[i].score = 0
            musicPoints[i].colour = .clear
        }
    }
    
    //ColourSound - function to find colour scores in size order in colour array.
    public func findMode() {
        //Make an array out of the current scores in the same order as the colours.
        var scores: [Int] = []
        for i in 0...5 {
            scores.append(colourPoints[i].score)
        }
        //Find the max score, and then find the index containing it, and add it to musicPoints. Set the score to 0 and run again to find the next biggest score until musicPoints is full.
        for j in 0...5 {
            let max = scores.max()
            for i in 0...5 {
                if scores[i] == max {
                    scores[i] = 0
                    musicPoints[j] = colourPoints[i]
                }
            }
        }
        //Remove any duplicate entries from musicPoints.
        for j in 0...4 {
            for i in (j+1)...5 {
                if musicPoints[i].colour == musicPoints[j].colour {
                    musicPoints[i].colour = .clear
                    musicPoints[i].score = 0
                }
            }
        }
        
        //Set mode according to whatever colour is biggest.
        switch musicPoints[0].colour {
        case .red:
            mode = "Ionian"

        case .yellow:
            mode = "Lydian"

        case .blue:
            mode = "Aeolian"

        case .green:
            mode = "Mixolydian"
            
        case .purple:
            mode = "Dorian"
           
        case .black:
            mode = "Phrygian"
            
        default: return
        }
    }
    //ColourSound - set MIDI notes to current mode.
    public func setMusic() {
        lastModeArray = modeArray
        print ("Array before mode change:", musicPoints)
        switch mode {
        case "Ionian":
            modeArray = [60, 62, 64, 65, 67, 69, 71]
        case "Lydian":
            modeArray = [60, 62, 64, 66, 67, 69, 71]
        case "Aeolian":
            modeArray = [60, 62, 63, 65, 67, 68, 70]
        case "Mixolydian":
            modeArray = [60, 62, 64, 65, 67, 69, 70]
        case "Dorian":
            modeArray = [60, 62, 63, 65, 67, 69, 70]
        case "Phrygian":
            modeArray = [60, 61, 63, 65, 67, 68, 70]
        default: return
        }
        playMusic()
    }
    //ColourSound - Function to play root C oscillator with octaves above and below. Limit amplitude to below 250.
    public func playMusic() {
        var amplitude1 = musicPoints[0].score/100
            if amplitude1 >= 250 {
                amplitude1 = 240
            }
            rootOsc.play(noteNumber: modeArray[0], velocity: MIDIVelocity(amplitude1))
            rootOsc.play(noteNumber: modeArray[0] + 12, velocity: MIDIVelocity(amplitude1))
            rootOsc.play(noteNumber: modeArray[0] - 12, velocity: MIDIVelocity(amplitude1))
     
    }
    
    //ColourSound - Function to intialise oscillators.
    public func setupOscillators() {
        //Set parameters for AudioKit nodes.
        rootOsc.filterCutoffFrequency = 500
        rootOsc.vibratoRate = 0.1
        rootOsc.vibratoDepth = 0.1
        
        synthOsc.filterCutoffFrequency = 1000
        
        synthOsc.attackDuration = 0.05
        synthOsc.decayDuration = 0.05
        synthOsc.releaseDuration = 0.05
        
        clarinetOsc.rampDuration = 1
        fluteOsc.rampDuration = 0.5
        
        //Declare variables for each instrument's performance.
        let synth = getSynth()
        synth.start()
        let piano = getPiano()
        piano.start()
        let clarinet = getClarinet()
        clarinet.start()
        let flute = getFlute()
        flute.start()
        
        //Define nodes for audio processing units.
        let rootVerb = AKCostelloReverb(rootOsc)
        rootVerb.presetLowRingingLongTailCostelloReverb()
        rootVerb.cutoffFrequency = 500
        
        let chorus = AKChorus(synthOsc)
        let synthVerb = AKChowningReverb(chorus)
        
        
        let pianoFilter = AKLowPassFilter(pianoOsc, cutoffFrequency: 300, resonance: 0)
        let pianoVerb = AKCostelloReverb(pianoFilter)
        let clarinetFilter = AKLowPassFilter(clarinetOsc, cutoffFrequency: 200, resonance: 0)
        let clarinetVerb = AKReverb(clarinetFilter)
        let fluteFilter = AKHighPassFilter(fluteOsc, cutoffFrequency: 1000, resonance: 0)
        let fluteChorus = AKChorus(fluteFilter)
        fluteChorus.depth = 3
        let fluteVerb = AKZitaReverb(fluteChorus)
        
        //Mix nodes together, connect to audio output and start audio engine.
        let mixer = AKMixer(rootOsc, synth, piano, clarinet, flute, clarinetVerb, pianoVerb, synthVerb, fluteVerb, rootVerb)
        AudioKit.output = mixer
        try!AudioKit.start()
    }
    
    //ColourSound - performance for synth pulse.
    func getSynth() -> AKPeriodicFunction {
        var lastNotePlayed: MIDINoteNumber = 0
        
        let performance = AKPeriodicFunction(frequency: 1) {
            let index = Int(random(in: 0...5))
            //Stop the last note played by this instrument.
            if lastNotePlayed != 0 {
                self.synthOsc.stop(noteNumber: MIDINoteNumber(lastNotePlayed))
            }
            //Set note and velocity according to a random index picked from the available colours.
            let currentNote = self.modeArray[self.musicPoints[index].note]
            let currentVel = self.musicPoints[index].score/20
            
            if self.musicPoints[index].colour != self.musicPoints[0].colour {
                self.synthOsc.play(noteNumber: currentNote, velocity: MIDIVelocity(currentVel))
            }
            lastNotePlayed = currentNote
            
            if self.modeArray != self.lastModeArray && self.lastModeArray[0] != 0 {
                self.synthOsc.stop(noteNumber: self.lastModeArray[self.musicPoints[0].note])
            }
        }
        return performance
    }
    
    //ColourSound - Define the piano instrument's performance.
    func getPiano() -> AKPeriodicFunction {
        let performance = AKPeriodicFunction(frequency: 0.5) {
            
            //Find how many colours are on the screen.
            self.findActiveColors()
            //If more than 2...
            if self.activeColours > 2 {
                //Choose a random index from the active colours.
                let index = Int(random(in: 0...Double(self.activeColours)))
                //Set note according to that index - takes the interval stored in the colour's index, and plays the corresponding MIDI note from the modes array.
                let currentNote =  Double((self.modeArray[self.musicPoints[index].note] - 12).midiNoteToFrequency())
                
                //Set velocity according to relevant colour's score.
                let currentVel = Double(self.musicPoints[index].score)/6000
                self.pianoOsc.trigger(frequency: currentNote, amplitude: currentVel)
            }
        }
        return performance
    }
    
    //ColourSound - Define notes played by clarinet emulator.
    func getClarinet() -> AKPeriodicFunction {
        let performance = AKPeriodicFunction(frequency: 0.5) {
            //Find how many colours are on the screen.
            self.findActiveColors()
            //If more than 3...
            if self.activeColours > 3 {
                //Choose a random index from the active colours.
                let index = Int(random(in: 0...Double(self.activeColours)))
                //Set note according to that index - takes the interval stored in the colour's index, and plays the corresponding MIDI note from the modes array.
                let currentNote =  Double((self.modeArray[self.musicPoints[index].note] - 12).midiNoteToFrequency())
                //Set velocity according to relevant colour's score.
                let currentVel = Double(self.musicPoints[index].score)/7500
                //Play note with this velocity.
                self.clarinetOsc.trigger(frequency: currentNote, amplitude: currentVel)
            }
        }
        return performance
    }
    //ColourSound - define flute instrument's performance.
    func getFlute() -> AKPeriodicFunction {
        let performance = AKPeriodicFunction(frequency: 0.25) {
            //Find how many colours are on the screen.
            self.findActiveColors()
            print ("Floot says", self.activeColours)
            //If more than 4...
            if self.activeColours > 4 {
                //Choose a random index from the active colours.
                let index1 = Int(random(in: 0...Double(self.activeColours)))
                let index2 = Int(random(in: 0...Double(self.activeColours)))
                let index3 = Int(random(in: 0...Double(self.activeColours)))
                //Set note according to that index - takes the interval stored in the colour's index, and plays the corresponding MIDI note from the modes array.
                let currentNote1 =  Double((self.modeArray[self.musicPoints[index1].note] - 12).midiNoteToFrequency())
                let currentNote2 =  Double((self.modeArray[self.musicPoints[index2].note] - 12).midiNoteToFrequency())
                let currentNote3 =  Double((self.modeArray[self.musicPoints[index3].note] - 12).midiNoteToFrequency())
                //Set velocity according to relevant colour's score.
                let currentVel1 = Double(self.musicPoints[index1].score)/7500
                let currentVel2 = Double(self.musicPoints[index2].score)/7500
                let currentVel3 = Double(self.musicPoints[index3].score)/7500
                
                let averageVel = (currentVel1 + currentVel2 + currentVel3)/3
                
                //Play a note, wait for a little, then play another, then another. Simulates a musical phrase based on random notes.
                self.clarinetOsc.trigger(frequency: currentNote1, amplitude: averageVel)
                let seconds = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.clarinetOsc.stop()
                    self.clarinetOsc.trigger(frequency: currentNote2, amplitude: averageVel)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 0.25) {
                    self.clarinetOsc.stop()
                    self.clarinetOsc.trigger(frequency: currentNote3, amplitude: averageVel)
                }
            }
        }
        return performance
    }
    
    //ColourSound - function to clear music playback.
    public func clearMusic() {
        for i in 40...80 {
            rootOsc.stop(noteNumber: MIDINoteNumber(i))
            rootOsc.stop(noteNumber: MIDINoteNumber(i))
            synthOsc.stop(noteNumber: MIDINoteNumber(i))
            clarinetOsc.stop()
            fluteOsc.stop()
        }
        activeColours = 0
    }
     
    
    // MARK: - Document
    public private(set) var data: CanvasData!
    
    /// reset data on canvas, this method will drop the old data object and create a new one.
    /// - Attention: SAVE your data before call this method!
    /// - Parameter redraw: if should redraw the canvas after, defaults to true
    open func resetData(redraw: Bool = true) {
        let oldData = data!
        let newData = CanvasData()
        // link registered observers to new data
        newData.observers = data.observers
        data = newData
        if redraw {
            self.redraw()
        }
        data.observers.data(oldData, didResetTo: newData)
    }
    
    public func undo() {
        if let data = data, data.undo() {
            redraw()
            //setMusic() - attempt at implementing undo with audio.
        }
    }
    
    public func redo() {
        if let data = data, data.redo() {
            redraw()
            //setMusic() - attempt at implementing redo with audio.
        }
    }
    
    //Function to find the amount of active colours on the screen.
    func findActiveColors(){
        activeColours = 0
        //Difficult to get colours down to zero, so sets a threshhold close to it.
        if musicPoints[0].score > 3 {
            activeColours += 1
        }
        else {return}
        
        for i in 1...5 {
            if musicPoints[i].colour != .clear && musicPoints[i].score > 3 {
                activeColours += 1
            }
        }
    }
    
    /// redraw elements in document
    /// - Attention: thie method must be called on main thread
    open func redraw(on target: RenderTarget? = nil) {
        
        guard let target = target ?? screenTarget else {
            return
        }
        
        data.finishCurrentElement()
        
        target.updateBuffer(with: drawableSize)
        target.clear()
        
        data.elements.forEach { $0.drawSelf(on: target) }
        
        /// submit commands
        target.commitCommands()
        
        actionObservers.canvas(self, didRedrawOn: target)
    }
    
    // MARK: - Bezier
    // optimize stroke with bezier path, defaults to true
    //    private var enableBezierPath = true
    private var bezierGenerator = BezierGenerator()
    
    // MARK: - Drawing Actions
    private var lastRenderedPan: Pan?
    
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator, force: CGFloat, isEnd: Bool = false) {
        var lines: [MLLine] = []
        let vertices = bezier.pushPoint(point)
        guard vertices.count >= 2 else {
            return
        }
        var lastPan = lastRenderedPan ?? Pan(point: vertices[0], force: force)
        let deltaForce = (force - (lastRenderedPan?.force ?? force)) / CGFloat(vertices.count)
        for i in 1 ..< vertices.count {
            let p = vertices[i]
            let pointStep = currentBrush.pointStep
            if  // end point of line
                (isEnd && i == vertices.count - 1) ||
                    // ignore step
                    pointStep <= 1 ||
                    // distance larger than step
                    (pointStep > 1 && lastPan.point.distance(to: p) >= pointStep)
            {
                let force = lastPan.force + deltaForce
                let pan = Pan(point: p, force: force)
                let line = currentBrush.makeLine(from: lastPan, to: pan)
                lines.append(contentsOf: line)
                lastPan = pan
                lastRenderedPan = pan
            }
        }
        render(lines: lines)
    }
    
    // MARK: - Rendering
    open func render(lines: [MLLine]) {
        data.append(lines: lines, with: currentBrush)
        // create a temporary line strip and draw it on canvas
        LineStrip(lines: lines, brush: currentBrush).drawSelf(on: screenTarget)
        /// submit commands
        screenTarget?.commitCommands()
    }
    
    open func renderTap(at point: CGPoint, to: CGPoint? = nil) {
        
        guard renderingDelegate?.canvas(self, shouldRenderTapAt: point) ?? true else {
            return
        }
        
        let brush = currentBrush!
        let lines = brush.makeLine(from: point, to: to ?? point)
        render(lines: lines)
    }
    
    /// draw a chartlet to canvas
    ///
    /// - Parameters:
    ///   - point: location where to draw the chartlet
    ///   - size: size of texture
    ///   - textureID: id of texture for drawing
    ///   - rotation: rotation angle of texture for drawing
    open func renderChartlet(at point: CGPoint, size: CGSize, textureID: String, rotation: CGFloat = 0) {
        
        let chartlet = Chartlet(center: point, size: size, textureID: textureID, angle: rotation, canvas: self)
        
        guard renderingDelegate?.canvas(self, shouldRenderChartlet: chartlet) ?? true else {
            return
        }
        
        data.append(chartlet: chartlet)
        chartlet.drawSelf(on: screenTarget)
        screenTarget?.commitCommands()
        setNeedsDisplay()
        
        actionObservers.canvas(self, didRenderChartlet: chartlet)
    }
    
    // MARK: - Touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let pan = Pan(touch: touch, on: self)
        lastRenderedPan = pan
        
        guard renderingDelegate?.canvas(self, shouldBeginLineAt: pan.point, force: pan.force) ?? true else {
            return
        }
        
        bezierGenerator.begin(with: pan.point)
        pushPoint(pan.point, to: bezierGenerator, force: pan.force)
        actionObservers.canvas(self, didBeginLineAt: pan.point, force: pan.force)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard bezierGenerator.points.count > 0 else { return }
        guard let touch = touches.first else {
            return
        }
        let pan = Pan(touch: touch, on: self)
        //ColourSound - variables to store touch force.
        let xForce = pan.force + 6
        let yForce = pan.force + 8
        guard pan.point != lastRenderedPan?.point else {
            return
        }
        //ColourSound - tracks current point.
        //Adds a catchment area around each point in the grid, triggering them if the finger enters that area.
        for i in 0 ..< canvasPoints.endIndex {
        //Check radius around each point for touch
            if canvasPoints[i].point.x - xForce < pan.point.x && canvasPoints[i].point.x + xForce > pan.point.x && canvasPoints[i].point.y - yForce < pan.point.y && canvasPoints[i].point.y + yForce > pan.point.y {
                               
            //Check if the triggered point has a different colour to the one we're painting with;
                if canvasPoints[i].colour != currentColour {
                                   
            //If it does, detract one point from that colour's score, provided it's not clear...
                    if colourCheck(colour: canvasPoints[i].colour) < 6 {
                        colourPoints[colourCheck(colour: canvasPoints[i].colour)].score -= 1
                    }
                                   
                    //...and change it to the current colour.
                    canvasPoints[i].colour = currentColour
                    //Increase the score of the current colour by one, provided the current colour is not clear.
                    if colourCheck(colour: currentColour) < 6 {
                        colourPoints[colourCheck(colour: currentColour)].score += 1
                    }
                    findMode() //Rearrange the musicPoints array based on new info.
                    setMusic()
                    
                    //End of ColourSound additions to this function.
                }
            }
        }
        pushPoint(pan.point, to: bezierGenerator, force: pan.force)
        actionObservers.canvas(self, didMoveLineTo: pan.point, force: pan.force)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        defer {
            bezierGenerator.finish()
            lastRenderedPan = nil
            data.finishCurrentElement()
        }
        
        guard let touch = touches.first else {
            return
        }
        let pan = Pan(touch: touch, on: self)
        let count = bezierGenerator.points.count
        
        if count >= 3 {
            pushPoint(pan.point, to: bezierGenerator, force: pan.force, isEnd: true)
        } else if count > 0 {
            renderTap(at: bezierGenerator.points.first!, to: bezierGenerator.points.last!)
        }
        
        let unfishedLines = currentBrush.finishLineStrip(at: Pan(point: pan.point, force: pan.force))
        if unfishedLines.count > 0 {
            render(lines: unfishedLines)
        }
        actionObservers.canvas(self, didFinishLineAt: pan.point, force: pan.force)
    }
}
