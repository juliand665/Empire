//
//  AppDelegate.swift
//  Empire
//
//  Created by Julian Dunskus on 04.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBAction func zoomOneToOne(_ sender: Any) {
		let window = NSApplication.shared.keyWindow
		guard let controller = window?.contentViewController as? ViewController else {
			return
		}
		let size = controller.world.size
		print(size)
		window?.setContentSize(size)
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		
	}
}
