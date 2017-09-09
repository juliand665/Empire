//
//  ViewController.swift
//  Empire
//
//  Created by Julian Dunskus on 04.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Cocoa
import Bitmap

let colonyColors = [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)].map(Pixel.init)

class ViewController: NSViewController {
	@IBOutlet weak var worldView: NSView!
	
	var framesRendered = 0
	var ticksApplied = 0
	var fpsTimer: Timer!
	var renderTimer: Timer!
	var updateQueue = DispatchQueue(label: "World Updating")
	var world: World!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let worldMap = #imageLiteral(resourceName: "world small").cgImage(forProposedRect: nil, context: nil, hints: nil)!
		let colonies = colonyColors.enumerated().map {
			Colony(named: "Colony \($0.offset)", color: $0.element)
		}
		world = World(from: worldMap, colonies: colonies)
		
		worldView.widthAnchor.constraint(equalTo: worldView.heightAnchor, multiplier: CGFloat(world.width) / CGFloat(world.height)).isActive = true
		
		updateQueue.async {
			while true {
				//print(".", terminator: "")
				self.world.update()
				self.ticksApplied += 1
			}
		}
	}
	
	override func viewDidAppear() {
		worldView.layer!.contentsGravity = kCAGravityResizeAspect
		worldView.layer!.magnificationFilter = kCAFilterNearest
		render()
		
		renderTimer = Timer(timeInterval: 0, repeats: true) { (timer) in
			self.render()
		}
		RunLoop.main.add(renderTimer, forMode: .commonModes)
		
		fpsTimer = Timer(timeInterval: 1, repeats: true) { (timer) in
			print(self.framesRendered, "FPS,", self.ticksApplied, "TPS")
			self.framesRendered = 0
			self.ticksApplied = 0
		}
		RunLoop.main.add(fpsTimer, forMode: .commonModes)
	}
	
	func render() {
		let render = world.render()
		worldView.layer!.contents = render
		framesRendered += 1
	}
}
