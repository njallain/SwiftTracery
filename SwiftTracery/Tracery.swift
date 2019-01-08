//
//  Tracery.swift
//  SwiftTracery
//
//  Created by Neil Allain on 1/3/19.
//  Copyright © 2019 Neil Allain. All rights reserved.
//

import Foundation


public struct Grammar {
	let fragments: Dictionary<String, Fragment>
}
public class Tracery {
	public init() {
	}
	public init(randomNumberGenerator: RandomNumberGenerator) {
		self.random = randomNumberGenerator
	}
	/**
	Parses the json and returns the grammar
	*/
	public func parse(text: String) throws -> Grammar {
		guard let data = text.data(using: .utf8) else {
			throw ParseError.invalidJson("Could not convert string to utf8 data")
		}
		return try parse(data: data)
	}
	/**
	Parse the json at the given url and returns the grammar
  */
	public func parse(url: URL) throws -> Grammar {
		let data = try Data(contentsOf: url)
		return try parse(data: data)
	}

	public func parse(data: Data) throws -> Grammar {
		let jsonObj = try JSONSerialization.jsonObject(with: data, options: [])
		guard let dictionary = jsonObj as? [String: Any] else {
			throw ParseError.invalidJson("Could not convert json to dictionary (json should contain a single object)")
		}
		return try parse(dictionary: dictionary)
	}
	public func parse(dictionary: Dictionary<String, Any>) throws -> Grammar {
		let fragments: Dictionary<String, Fragment> =  try dictionary.mapValues { obj in
			if let text = obj as? String {
				return try FragmentParser.parse(text: text)
			} else if let list = obj as? [String] {
				let fragments: Array<Fragment> = try list.map { try FragmentParser.parse(text: $0) }
				return RandomFragment(fragments: fragments)
			} else {
				throw ParseError.invalidJson("expected either a single string or array of strings")
			}
		}
		return Grammar(fragments: fragments)
	}
	
	public func generate(start: String, grammar: Grammar) -> String {
		return grammar.fragments[start]?.generate(self, parameters: grammar.fragments) ?? ""
	}
	var random: RandomNumberGenerator = SystemRandomNumberGenerator()
}

extension Tracery: FragmentGenerator {
	func randomFragment(_ fragments: Array<Fragment>) -> Fragment? {
		guard fragments.count > 0 else { return nil }
		return fragments[Int(random.next(upperBound: UInt(fragments.count)))]
	}
	
}
