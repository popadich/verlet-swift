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
    
    var solver: Solver = Solver(withParticleCount: 0)
    private var object_spawn_delay : CGFloat    = 0.125
    private var object_min_radius : CGFloat     = 4.0
    private var object_max_radius : CGFloat     = 20.0
    private var max_angle : CGFloat             = 1.0
    var object_spawn_position : CGVector = CGVector.zero
    var object_spawn_speed : CGFloat = -1200.0
    var max_objects_count: Int = 0
    var frame_rate : Int = 30
    var eventTimer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        countDownTimer.delegate = self
        setupPrefs()
        
        // Set up Verlet Solver
        solver.delegate = self
        solver.setSubStepsCount(8)
        solver.setSimulationUpdateRate(frame_rate)
        
        setConstraints()

    }

    @IBAction func startButtonClicked(_ sender: Any) {
        if countDownTimer.isPaused {
            countDownTimer.resumeTimer()
            startParticleEvents()
        } else {
            countDownTimer.duration = TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime"))
            countDownTimer.startTimer()
            startParticleEvents()
        }
        configureButtons()
    }
    
    @IBAction func stopButtonClicked(_ sender: Any) {
        countDownTimer.stopTimer()
        solver.stopAnimation()
        stopParticleEvents()
        configureButtons()
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        countDownTimer.resetTimer()
        updateDisplay(for: TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime")))
        resetParticleEvents()
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
      stopParticleEvents()
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
        max_objects_count = UserDefaults.standard.integer(forKey: "maximumNumberOfParticles")
        countDownTimer.resetTimer()
        updateDisplay(for: TimeInterval(UserDefaults.standard.integer(forKey: "selectedTime")))
        resetParticleEvents()
        configureButtons()
    }
    
    func checkForResetAfterPrefsChange() {
        if countDownTimer.isStopped || countDownTimer.isPaused {
            updateFromPrefs()
        } else {
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new settings?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning
            
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
}

extension ViewController: SolverProtocol {
    //MARK: - Solver Protocol
    
    func updateAnimationView(_ solver: Solver) {
        animationView.needsDisplay = true
    }
    
    func animationHasFinished(_ solver: Solver) {
        print("Animation has finished")
    }

}


extension ViewController {
    //MARK: - Verlet Events Engine
    
    func particleEvent() {
        if solver.particlesArray.count < max_objects_count {

            let particle = solver.addParticle(position: object_spawn_position, withRadius: CGFloat.random(in: object_min_radius...object_max_radius))
            
            let t = solver.getTime()
            let angle : CGFloat  = max_angle * sin(t) + CGFloat.pi * 0.5
            let velocity = CGVector(dx: object_spawn_speed * cos(angle), dy: object_spawn_speed * sin(angle))

            solver.setObjectVelocity(object: particle, velocity: velocity)
            
            // have to pass the array every time because it's call by value
            animationView.particlesArray = solver.particlesArray
        }
    }
    
    func setConstraints() {
        let constraintHeight = CGRectGetHeight(animationView.bounds)
        let constraintWidth = CGRectGetWidth(animationView.bounds)
        let widthOffset = (constraintWidth - constraintHeight)/2
        let constraintRadius = constraintHeight / 2.0
        let centerPoint = CGPointMake(constraintHeight - constraintRadius + widthOffset, constraintHeight - constraintRadius)
        
        object_spawn_position = CGVectorMake(centerPoint.x, centerPoint.y + constraintRadius - 40.0)
        
        animationView.setConstraint(position: centerPoint, withRadius: constraintRadius)
        solver.setConstraint(position: centerPoint, withRadius: constraintRadius)
    }
    
    func startParticleEvents() {
        setConstraints()
        max_objects_count = UserDefaults.standard.integer(forKey: "maximumNumberOfParticles")
        solver.startAnimation()
        eventTimer = Timer.scheduledTimer(withTimeInterval: object_spawn_delay, repeats: true) { timer in
            self.particleEvent()
        }
    }
    
    func stopParticleEvents() {
        solver.stopAnimation()
        eventTimer?.invalidate()
        eventTimer = nil
    }
    
    func resetParticleEvents() {
        solver.resetAnimation()
        animationView.particlesArray = solver.particlesArray
    }
}
