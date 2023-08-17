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
    @IBOutlet weak var animationView: AnimationView!
    
    var countDownTimer = CountDownTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countDownTimer.delegate = self
        setupPrefs()
    }

    @IBAction func startButtonClicked(_ sender: Any) {
        if countDownTimer.isPaused {
            countDownTimer.resumeTimer()
        } else {
            countDownTimer.duration = TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime"))
            countDownTimer.startTimer()
        }
        configureButtons()    }
    
    @IBAction func stopButtonClicked(_ sender: Any) {
        countDownTimer.stopTimer()
        configureButtons()
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        countDownTimer.resetTimer()
        updateDisplay(for: TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime")))
        configureButtons()
    }
    
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
      configureButtons()
  }
}

extension ViewController : NSUserInterfaceValidations {

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
    func configureButtons() {
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
    }
    
    func validateUserInterfaceItem(_ anItem: NSValidatedUserInterfaceItem) -> Bool {
        let action = anItem.action
        
        if action == #selector(startTimerMenuItemSelected) {
            if !(countDownTimer.isStopped || countDownTimer.isPaused) {
                return false;
            }
        }
        if action == #selector(stopTimerMenuItemSelected) {
            if (countDownTimer.isPaused || countDownTimer.isStopped) {
                return false;
            }
        }
        if action == #selector(resetTimerMenuItemSelected) {
            if !countDownTimer.isPaused {
                return false;
            }
        }
        return true
    }
}

extension ViewController {
    
    // MARK: - Preferences
    
    func setupPrefs() {
        updateDisplay(for: TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime")))
        
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName,
                                               object: nil, queue: nil) {
            (notification) in
            self.checkForResetAfterPrefsChange()
        }
    }
    
    func updateFromPrefs() {
        self.countDownTimer.duration = TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime"))

        countDownTimer.resetTimer()
        updateDisplay(for: TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime")))
        configureButtons()
    }
    
    func checkForResetAfterPrefsChange() {
        if countDownTimer.isStopped || countDownTimer.isPaused {
            // 1
            updateFromPrefs()
        } else {
            // 2
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new settings?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning
            
            // 3
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            
            // 4
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
}
