//
//  Map.swift
//  Empire
//
//  Created by Julian Dunskus on 09.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Cocoa

class Map {
	let name: String
	let fileExtension: String
	let directory: URL
	private lazy var url: URL = directory.appendingPathComponent("\(name).\(fileExtension)", isDirectory: false)
	private lazy var rawURL: URL = directory.appendingPathComponent("\(name)_raw.\(fileExtension)", isDirectory: false)
	
	/// - Parameter fileExtension: extension of the file, without the "." (e.g. "png")
	init(named name: String, withExtension fileExtension: String, in directory: URL) {
		self.name = name
		self.fileExtension = fileExtension
		self.directory = directory
	}
	
	private var _rawImage: NSImage?
	var rawImage: NSImage? {
		_rawImage = _rawImage ?? NSImage(contentsOf: rawURL) ?? NSImage(contentsOf: url)
		return _rawImage
	}
	
	private var _backgroundImage: NSImage?
	var backgroundImage: NSImage? {
		_backgroundImage = _backgroundImage ?? NSImage(contentsOf: url)
		return _backgroundImage
	}
}

class MapManager {
	static let shared = MapManager()
	
	let fileManager = FileManager.default
	let empireDirectory: URL
	let mapsDirectory: URL
	var maps: [String: Map] = [:]
	
	init() {
		guard let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
			fatalError("Could not access user's Application Support directory! Cancelling map loading.")
		}
		empireDirectory = applicationSupport.appendingPathComponent("Empire", isDirectory: true)
		mapsDirectory = empireDirectory.appendingPathComponent("maps", isDirectory: true)
		
		do {
			try fileManager.createDirectory(at: mapsDirectory, withIntermediateDirectories: true)
		} catch {
			print("Could not create maps directory in Application Support!")
			print(error.localizedDescription)
		}
		
		do {
			try reloadMaps()
		} catch {
			print("Could not load maps in \(mapsDirectory.absoluteString)")
		}
	}
	
	func reloadMaps() throws {
		let contentURLs = try fileManager.contentsOfDirectory(at: mapsDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
		maps = [:]
		for url in contentURLs {
			let fullName = url.lastPathComponent
			let parts = fullName.components(separatedBy: ".")
			guard parts.count == 2, let name = parts.first, let fileExtension = parts.last else {
				print("Malformed file named \(fullName); skipping.")
				continue
			}
			guard !name.hasSuffix("_raw") else { continue }
			maps[name] = Map(named: name, withExtension: fileExtension, in: mapsDirectory)
		}
	}
}
