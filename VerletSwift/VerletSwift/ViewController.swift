//
//  ViewController.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/15/23.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var timeLeftField: NSTextField!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func startButtonClicked(_ sender: NSButton) {
        timeLeftField.stringValue = "Start"
    }
    
    @IBAction func stopButtonClicked(_ sender: NSButton) {
        timeLeftField.stringValue = "Stop"
    }
    
    @IBAction func resetButtonClicked(_ sender: NSButton) {
        timeLeftField.stringValue = "Reset"
    }
    
}

