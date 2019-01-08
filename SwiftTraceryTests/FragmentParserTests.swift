//
//  FragmentParserTests.swift
//  SwiftTraceryTests
//
//  Created by Neil Allain on 1/6/19.
//  Copyright © 2019 Neil Allain. All rights reserved.
//

import XCTest
@testable import SwiftTracery

class FragmentParserTests: XCTestCase {
	let generator = MockGenerator()
	override func setUp() {
		generator.index = 0
	}
	

	func testParseTag() {
		let fragment = parse("#testtag#")
		let s = fragment.generate(generator, parameters: ["testtag": "replace"])
		XCTAssertEqual("replace", s)
	}
	
	func testEscapedTagDelimeter() {
		let fragment = parse("\\#55")
		XCTAssertEqual("#55", fragment.generate(generator, parameters:["55": "nope"]))
	}
	func testEmptyEscapedTag() {
		let fragment = parse("\\#")
		XCTAssertEqual("#", fragment.generate(generator, parameters:["55": "nope"]))
	}
	func testParseTagWithParameters() {
		let fragment = parse("#[p1:#a#][p2:#b#]testtag#")
		let aFrag = CompositeFragment(fragments: [DynamicFragment(name: "p1"), " + ", DynamicFragment(name: "p2")])
		let s = fragment.generate(generator, parameters: ["a": "1", "b": "2", "testtag": aFrag])
		XCTAssertEqual("1 + 2", s)
	}
	
	func testParseComposite() {
		let fragment = parse("equation is #a# + #b#")
		let s = fragment.generate(generator, parameters: ["a": "3", "b": "4"])
		XCTAssertEqual("equation is 3 + 4", s)
	}
	private func parse(_ text: String) -> Fragment {
		do {
			return try FragmentParser.parse(text: text)
		} catch {
			XCTFail("\(error.localizedDescription)")
		}
		return "fail"
	}
}
