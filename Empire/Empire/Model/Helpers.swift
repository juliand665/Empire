//
//  Helpers.swift
//  Empire
//
//  Created by Julian Dunskus on 04.09.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Foundation

// MARK: -
// MARK: Randomization

extension Int {
	static func randomValue(lessThan bound: Int) -> Int {
		return Int(arc4random_uniform(UInt32(bound)))
	}
}

extension BinaryFloatingPoint {
	static func randomValue(in bounds: (lo: Double, hi: Double)? = nil) -> Self {
		return Self(arc4random()) / Self(UInt32.max)
	}
}

extension Bool {
	static func randomBool() -> Bool {
		return arc4random() & 1 == 0
	}
}

// MARK: -
// MARK: True Modulo

infix operator %%: MultiplicationPrecedence
infix operator %%=: AssignmentPrecedence

extension Int {
	static func %%(lhs: Int, rhs: Int) -> Int {
		var copy = lhs
		copy %%= rhs
		return copy
	}
	
	static func %%=(lhs: inout Int, rhs: Int) {
		lhs %= rhs
		if lhs < 0 {
			lhs += rhs
		}
	}
}
