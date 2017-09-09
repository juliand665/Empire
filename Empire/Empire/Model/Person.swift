//
//  Person.swift
//  Empire
//
//  Created by Julian Dunskus on 04.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Bitmap

typealias Position = (x: Int, y: Int)

struct RandomChance {
	var probability: Double
	
	init(of probability: Double) {
		self.probability = probability
	}
	
	func isFulfilled() -> Bool {
		return .randomValue() < probability
	}
}

let strengthDecreaseChance = RandomChance(of: 0.25) // per birth
let diseaseCureChance = RandomChance(of: 0.01) // per tick
let diseaseHeredityChance = RandomChance(of: 0.2)
let diseaseMutationChance = RandomChance(of: 0.00001)
let diseaseSpreadChance = RandomChance(of: 0.5) // per encounter
let reproductionThreshold = 15

class Person {
	unowned var world: World
	private var position: Position
	private var colony: Colony
	private var age = 0
	private var strength: Int
	private var reproductionValue: Int
	private var isDiseased = false
	private var isAlive = true
	
	@discardableResult init(in world: World, at position: Position, partOf colony: Colony) {
		self.world = world
		self.position = position
		self.colony = colony
		self.strength = 20 + .randomValue(lessThan: 20) // 20...40
		self.reproductionValue = .randomValue(lessThan: reproductionThreshold)
		
		world[position].person = self
	}
	
	@discardableResult init(childOf parent: Person, at position: Position) {
		self.world = parent.world
		self.position = position
		self.colony = parent.colony
		self.strength = parent.strength
		self.reproductionValue = .randomValue(lessThan: reproductionThreshold)
		
		let diseaseChance = parent.isDiseased ? diseaseHeredityChance : diseaseMutationChance
		isDiseased = diseaseChance.isFulfilled()
		
		if strengthDecreaseChance.isFulfilled() {
			strength = .randomValue(lessThan: strength)
		}
		
		world[position].person = self
	}
	
	var color: Pixel {
		var color = colony.color
		if isDiseased {
			color.alpha = UInt8(Int(color.alpha) * 7/8)
		}
		return color
	}
	
	func update() {
		guard isAlive else { return }
		
		age += 1
		reproductionValue += 1
		if isDiseased {
			strength -= 1 // TODO try aging faster instead
		}
		
		// possible death
		guard age < strength else {
			die()
			return
		}
		
		// possible cure, if diseased
		if isDiseased && diseaseCureChance.isFulfilled() {
			isDiseased = false
		}
		
		// movement
		var target = position
		if .randomBool() {
			target.x += .randomBool() ? 1 : -1
			target.x %%= world.width
		} else {
			target.y += .randomBool() ? 1 : -1
			target.y %%= world.height
		}
		
		switch world[target] {
		case .land(let other?): // already occupied
			if other.colony === colony {
				if isDiseased && diseaseSpreadChance.isFulfilled() {
					other.isDiseased = true
				}
			} else {
				if strength < other.strength {
					die()
					return
				} else {
					other.die()
					reproductionValue += reproductionThreshold
					fallthrough
				}
			}
		case .land(with: nil):
			let oldPosition = move(to: target)
			
			if reproductionValue > reproductionThreshold {
				reproductionValue -= reproductionThreshold
				Person(childOf: self, at: oldPosition)
			}
		case .water:
			break
		}
	}
	
	@discardableResult func move(to target: Position) -> Position {
		precondition(world[target].person == nil)
		defer {
			position = target
		}
		world[target].person = self
		world[position].person = nil
		return position
	}
	
	func die() {
		world[position].person = nil
		isAlive = false
	}
}
