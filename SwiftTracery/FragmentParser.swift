//
//  FragmentParser.swift
//  SwiftTracery
//
//  Created by Neil Allain on 1/5/19.
//  Copyright © 2019 Neil Allain. All rights reserved.
//

import Foundation

public enum ParseError: Error {
	case unmatchedTagDelimeter(String)
	case noParameterSeparator(String)
	case unmatchedParameterDelimiter(String)
	case unknownModifier(String)
	case invalidJson(String)
	
}
enum FragmentParser {
	private static let paramStartChar: Character = "["
	private static let paramEndChar: Character = "]"
	private static let fragmentChar: Character = "#"
	private static let modifierChar: Character = "."
	private static let paramNameChar: Character = ":"
	
	static func parse(text: String) throws -> Fragment {
		return try parse(partial: text[...])
	}
	private static func parse(partial: Substring) throws -> Fragment {
		var rest = partial
		var fragments = [Fragment]()
		while !rest.isEmpty {
			if let tagStartIndex = rest.firstIndex(of: fragmentChar) {
				if tagStartIndex != rest.startIndex {
					let beforeTag = rest.index(before: tagStartIndex)
					if rest[beforeTag] == "\\" {
						// tag delimiter is escaped
						let pre = rest[..<beforeTag]
						fragments.append(String(pre) + "#")
						let afterTag = rest.index(after: tagStartIndex)
						rest = rest[afterTag...]
						continue
					} else {
						let pre = rest[..<tagStartIndex]
						fragments.append(String(pre))
					}
				}
				let (fragment, afterTag) = try parse(tag: rest[rest.index(after: tagStartIndex)...])
				fragments.append(fragment)
				rest = afterTag
			} else {
				if !rest.isEmpty {fragments.append(String(rest))}
				break
			}
		}
		return CompositeFragment(fragments: fragments)
	}
	private static func parse(tag: Substring) throws -> (Fragment, Substring){
		var rest: Substring = tag
		var paramFragments = FragmentParameters()
		while let paramStartIndex = rest.firstIndex(of: paramStartChar) {
			guard let paramEndIndex = rest.firstIndex(of: paramEndChar) else {
					throw ParseError.unmatchedParameterDelimiter("\(rest)")
			}
			let paramBegin = rest.index(after: paramStartIndex)
			let paramText = rest[paramBegin..<paramEndIndex]
			let (name, parm) = try parse(parameter: paramText)
			paramFragments[name] = parm
			rest = rest[rest.index(after: paramEndIndex)...]
		}
		guard let endIndex = rest.firstIndex(of: fragmentChar) else {
			throw ParseError.unmatchedTagDelimeter("\(tag)")
		}
		
		let tagParts = rest[ ..<endIndex].split(separator: modifierChar)
		var tagFragment: Fragment = DynamicFragment(name: String(tagParts[0]))
		rest = rest[rest.index(after: endIndex)...]
		for modifierText in tagParts[1...] {
			try tagFragment = parse(modifier: modifierText, modified: tagFragment)
		}
		if paramFragments.count > 0 {
			tagFragment = ParameterizedFragment(parameters: paramFragments, fragment: tagFragment)
		}
		return (tagFragment, rest)
	}


	
	private static func parse(parameter: Substring) throws -> (String, Fragment) {
		guard let nameEndIndex = parameter.firstIndex(of: paramNameChar) else {
			throw ParseError.noParameterSeparator("\(parameter)")
		}
		let name = parameter[..<nameEndIndex].trimmingCharacters(in: .whitespaces)
		let fragment = try parse(partial: parameter[parameter.index(after: nameEndIndex)...])
		return (name, fragment)
	}

	private static func parse(modifier: Substring, modified fragment: Fragment) throws -> Fragment {
		switch modifier {
		case "a":
			return ModifiedFragment.a(fragment)
		case "capitalize":
			return ModifiedFragment.capitalize(fragment)
		case "capitalizeAll":
			return ModifiedFragment.capitalizeAll(fragment)
		case "s":
			return ModifiedFragment.plural(fragment)
		case "ed":
			return ModifiedFragment.pastTense(fragment)
		case "comma":
			return ModifiedFragment.comma(fragment)
		case "inQuotes":
			return ModifiedFragment.quote(fragment)
		default:
			throw ParseError.unknownModifier("\(modifier)")
		}
	}
}
