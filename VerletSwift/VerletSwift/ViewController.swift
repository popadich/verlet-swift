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
    
    var countDownTimer = CountDownTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countDownTimer.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func startButtonClicked(_ sender: Any) {
        if countDownTimer.isPaused {
            countDownTimer.resumeTimer()
        } else {
            countDownTimer.duration = TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime"))
            countDownTimer.startTimer()
        }
        configureButtonsAndMenus()    }
    
    @IBAction func stopButtonClicked(_ sender: Any) {
        countDownTimer.stopTimer()
        configureButtonsAndMenus()
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        countDownTimer.resetTimer()
        updateDisplay(for: TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime")))
        configureButtonsAndMenus()    }
    
    // MARK: - IBActions - menus

    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
      startButtonClicked(sender)
    }

    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
      stopButtonClicked(sender)
    }

    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
      resetButtonClicked(sender)
    }
}

extension ViewController: CountDownTimerProtocol {
    // MARK: Egg Timer Protocol

  func timeRemainingOnTimer(_ timer: CountDownTimer, timeRemaining: TimeInterval) {
    updateDisplay(for: timeRemaining)
  }

  func timerHasFinished(_ timer: CountDownTimer) {
      

      updateDisplay(for: 0)
      configureButtonsAndMenus()
  }
}

extension ViewController {

  // MARK: - Display

    func updateDisplay(for timeRemaining: TimeInterval) {
        timeLeftField.stringValue = textToDisplay(for: timeRemaining)
    }

    private func textToDisplay(for timeRemaining: TimeInterval) -> String {
        if timeRemaining == 0 {
            return "Done!"
        }
        
        let minutesRemaining = floor(timeRemaining / 60)
        let secondsRemaining = timeRemaining - (minutesRemaining * 60)
        
        let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        
        return timeRemainingDisplay
    }
    
    // configure
    func configureButtonsAndMenus() {
        let enableStart: Bool
        let enableStop: Bool
        let enableReset: Bool
        
        if countDownTimer.isStopped {
            enableStart = true
            enableStop = false
            enableReset = false
        } else if countDownTimer.isPaused {
            enableStart = true
            enableStop = false
            enableReset = true
        } else {
            enableStart = false
            enableStop = true
            enableReset = false
        }
        
        startButton.isEnabled = enableStart
        stopButton.isEnabled = enableStop
        resetButton.isEnabled = enableReset
        
//        if let appDel = NSApplication.shared.delegate as? AppDelegate {
//            appDel.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
//        }
    }
    
}
