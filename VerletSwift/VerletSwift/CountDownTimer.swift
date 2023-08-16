//
//  CountDownTimer.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/16/23.
//

import Foundation


class CountDownTimer {
    var delegate: CountDownTimerProtocol?

    var timer: Timer? = nil
    var startTime: Date?
    var duration: TimeInterval = 360      // default = 6 minutes
    var elapsedTime: TimeInterval = 0

    var isStopped: Bool {
        return timer == nil && elapsedTime == 0
    }
    var isPaused: Bool {
        return timer == nil && elapsedTime > 0
    }
    
    func timerAction() {
        
        guard let startTime = startTime else {
            return
        }
        
        elapsedTime = -startTime.timeIntervalSinceNow
        
        let secondsRemaining = (duration - elapsedTime).rounded()
        
        if secondsRemaining <= 0 {
            resetTimer()
            delegate?.timerHasFinished(self)
        } else {
            delegate?.timeRemainingOnTimer(self, timeRemaining: secondsRemaining)
        }
    }


    func startTimer() {
        startTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.timerAction()
        }
        timerAction()
    }
    
    
    func resumeTimer() {
        startTime = Date(timeIntervalSinceNow: -elapsedTime)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.timerAction()
        }
        timerAction()
    }
    
    
    func stopTimer() {
        // really just pauses the timer
        timer?.invalidate()
        timer = nil
        
        timerAction()
    }
    
    
    func resetTimer() {
        // stop the timer & reset back to start
        timer?.invalidate()
        timer = nil
        
        startTime = nil
        duration = 360
        elapsedTime = 0
        
        timerAction()
    }

}

protocol CountDownTimerProtocol {
    func timeRemainingOnTimer(_ timer: CountDownTimer, timeRemaining: TimeInterval)
    func timerHasFinished(_ timer: CountDownTimer)
}
