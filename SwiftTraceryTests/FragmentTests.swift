//
//  FragmentTests.swift
//  SwiftTraceryTests
//
//  Created by Neil Allain on 1/5/19.
//  Copyright © 2019 Neil Allain. All rights reserved.
//

import XCTest
@testable import SwiftTracery

class FragmentTests: XCTestCase {
	let generator = MockGenerator()
	override func setUp() {
		generator.index = 0
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testString() {
		XCTAssertEqual("yes", "yes".generate(generator, parameters: ["a":"b"]))
	}
	func testRandomFragment() {
		let a = RandomFragment(fragments: ["a", "b"])
		generator.index = 0
		XCTAssertEqual("a", a.generate(generator, parameters: ["c": "d"]))
		generator.index = 1
		XCTAssertEqual("b", a.generate(generator, parameters: ["c": "d"]))
	}
	
	func testCompositeFragment() {
		let f = CompositeFragment(fragments: ["test", " ", RandomFragment(fragments: ["a", "b"])])
		XCTAssertEqual("test a", f.generate(generator, parameters: [:]))
	}
	func testParemeterizedFragment() {
		let p = DynamicFragment(name: "d")
		XCTAssertEqual("x", p.generate(generator, parameters: ["a": "y", "d": "x"]))
	}
}
