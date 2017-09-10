//
//  World.swift
//  Empire
//
//  Created by Julian Dunskus on 04.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Bitmap

class World {
	private(set) var width, height: Int
	private(set) var colonies: [Colony]
	private var background: Bitmap
	private var tiles: [[Tile]] = []
	
	init(from backgroundImage: CGImage, colonies: [Colony]) {
		self.background = Bitmap(from: backgroundImage)
		self.tiles = background.map(Tile.init)
		self.width = background.width
		self.height = background.height
		self.colonies = colonies
		
		for colony in colonies {
			while true {
				let position = (Int.randomValue(lessThan: width), Int.randomValue(lessThan: height))
				if case .land(nil) = self[position] {
					Person(in: self, at: position, partOf: colony)
					break
				}
			}
		}
	}
	
	subscript(position: Position) -> Tile {
		get { return tiles[position.y][position.x]            }
		set {        tiles[position.y][position.x] = newValue }
	}
	
	var size: CGSize {
		return background.size
	}
	
	var people: [Person] {
		return tiles.flatMap { $0.flatMap { $0.person } }
	}
	
	func isWithinBounds(_ position: Position) -> Bool {
		if case (0..<width, 0..<height) = position {
			return true
		} else {
			return false
		}
	}
	
	func update() {
		for line in tiles {
			for tile in line {
				guard let person = tile.person else { continue }
				person.update()
			}
		}
		for person in people {
			person.update()
		}
	}
	
	func render() -> CGImage {
		let pixels = tiles.flatMap { $0.map { $0.color } }
		let bitmap = Bitmap(width: width, height: height, pixels: pixels)!
		return bitmap.cgImage()
	}
}

enum Tile {
	case water
	case land(with: Person?)
	
	init(from pixel: Pixel) {
		switch pixel {
		case .green:
			self = .land(with: nil)
		case .blue:
			self = .water
		default:
			fatalError("Unrecognized color: \(pixel)")
		}
	}
	
	var person: Person? {
		get {
			switch self {
			case let .land(person):
				return person
			default:
				return nil
			}
		}
		set {
			switch self {
			case .water:
				fatalError("No swimming!")
			case .land:
				self = .land(with: newValue)
			}
		}
	}
	
	var color: Pixel {
		return person?.color ?? .clear
	}
}
