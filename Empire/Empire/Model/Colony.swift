//
//  Colony.swift
//  Empire
//
//  Created by Julian Dunskus on 08.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Bitmap

class Colony {
	private(set) var color: Pixel
	private(set) var name: String
	
	init(named name: String, color: Pixel) {
		self.name = name
		self.color = color
	}
}
