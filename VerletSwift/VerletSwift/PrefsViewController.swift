//
//  PrefsViewController.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/15/23.
//

import Cocoa

class PrefsViewController: NSViewController {

    @IBOutlet weak var presetsPopup: NSPopUpButton!
    @IBOutlet weak var customSlider: NSSlider!
    @IBOutlet weak var customTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        showExistingPrefs()
    }
    
    @IBAction func popupValueChanged(_ sender: NSPopUpButton) {
        if sender.selectedItem?.title == "Custom" {
            customSlider.isEnabled = true
            return
        }
        
        let newTimerDuration = sender.selectedTag()
        customSlider.integerValue = newTimerDuration
        showSliderValueAsText()
        customSlider.isEnabled = false
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        showSliderValueAsText()
    }
    
    @IBAction func cancleButtonClicked(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func okButtonClicked(_ sender: Any) {
        saveNewPrefs()
        view.window?.close()
    }
    
    func showExistingPrefs() {
        
        let selectedTimeInMinutes = UserDefaults.standard.integer(forKey: "selectedTime") / 60
        
        
        presetsPopup.selectItem(withTitle: "Custom")
        customSlider.isEnabled = true
        
        
        for item in presetsPopup.itemArray {
            if item.tag == selectedTimeInMinutes {
                presetsPopup.select(item)
                customSlider.isEnabled = false
                break
            }
        }
        
        
        customSlider.integerValue = selectedTimeInMinutes
        showSliderValueAsText()
    }
    
    
    func showSliderValueAsText() {
        let newTimerDuration = customSlider.integerValue
        let minutesDescription = (newTimerDuration == 1) ? "minute" : "minutes"
        customTextField.stringValue = "\(newTimerDuration) \(minutesDescription)"
    }

    func saveNewPrefs() {
        UserDefaults.standard.setValue(customSlider.integerValue * 60, forKey: "selectedTime")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"),
                                      object: nil)
    }

}
