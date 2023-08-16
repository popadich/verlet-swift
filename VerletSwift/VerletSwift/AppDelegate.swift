//
//  AppDelegate.swift
//  VerletSwift
//
//  Created by Alex Popadich on 8/15/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let userDefaultsDictionary : Dictionary = [ "verletTitle" : "Verlet Physics",
                                                "maximumNumberOfParticles" : 10,
                                                "particleSizeMaximum" : 20,
                                                "particleSizeMinimum" : 3,
                                                "frameRate" : 60,
                                                "selectedTime" : 360] as [String : Any]



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        UserDefaults.standard.register(defaults: userDefaultsDictionary)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

