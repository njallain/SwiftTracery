//
//  Fragment.swift
//  SwiftTracery
//
//  Created by Neil Allain on 1/5/19.
//  Copyright © 2019 Neil Allain. All rights reserved.
//

import Foundation


typealias FragmentParameters = [String: Fragment]

protocol FragmentGenerator {
	func randomFragment(_ fragments: Array<Fragment>) -> Fragment?
}

protocol Fragment {
	func generate(_ generator: FragmentGenerator, parameters: FragmentParameters) -> String
}

extension String: Fragment {
	func generate(_ generator: FragmentGenerator, parameters: FragmentParameters) -> String { return self }
}

struct RandomFragment: Fragment {
	let fragments: [Fragment]
	func generate(_ generator: FragmentGenerator, parameters: FragmentParameters) -> String {
		return generator.randomFragment(fragments)?.generate(generator, parameters: parameters) ?? ""
	}
}

struct CompositeFragment: Fragment {
	let fragments: [Fragment]
	func generate(_ generator: FragmentGenerator, parameters: FragmentParameters) -> String {
		let parts = fragments.map { $0.generate(generator, parameters: parameters)}
		return parts.joined()
	}
}

struct ParameterizedFragment: Fragment {
	let parameters: FragmentParameters
	let fragment: Fragment
	func generate(_ generator: FragmentGenerator, parameters: FragmentParameters) -> String {
		var localParams: [String: Fragment] = self.parameters.mapValues { $0.generate(generator, parameters: parameters) }
		localParams.merge(parameters) { local, _ in local }
		return fragment.generate(generator, parameters: localParams)
	}
}

struct DynamicFragment: Fragment {
	let name: String
	func generate(_ generator: FragmentGenerator, parameters: FragmentParameters) -> String {
		guard let fragment = parameters[name] else { return "#\(name)#" }
		return fragment.generate(generator, parameters:parameters)
	}
}

enum ModifiedFragment: Fragment {
	case plural(Fragment)
	case a(Fragment)
	case capitalize(Fragment)
	case capitalizeAll(Fragment)
	case quote(Fragment)
	case comma(Fragment)
	case pastTense(Fragment)
	
	func generate(_ generator: FragmentGenerator, parameters: FragmentParameters) -> String {
		switch self {
		case .plural(let fragment):
			return ModifiedFragment.pluralize(fragment.generate(generator, parameters: parameters))
		case .a(let fragment):
			return ModifiedFragment.addArticle(fragment.generate(generator, parameters: parameters))
		case .capitalize(let fragment):
			return ModifiedFragment.cap(fragment.generate(generator, parameters: parameters))
		case .capitalizeAll(let fragment):
			return fragment.generate(generator, parameters: parameters).capitalized
		case .quote(let fragment):
			return "\"\(fragment.generate(generator, parameters: parameters))\""
		case .comma(let fragment):
			return ModifiedFragment.addComma(fragment.generate(generator, parameters: parameters))
		case .pastTense(let fragment):
			return ModifiedFragment.makePastTense(fragment.generate(generator, parameters: parameters))
		}
	}
	
	private static func pluralize(_ s: String) -> String {
		guard let last = s.last else { return s }
		switch last {
		case "y":
			guard let secondLast = s.dropLast().last else { return s }
			if vowels.contains(character: secondLast) { return s + "s" }
			return s.dropLast() + "ies"
		case "x":
			return s + "en"
		case "z", "h", "s":
			return s + "es"
		default:
			return s + "s"
		}
	}
	private static func addArticle(_ s: String) -> String {
		guard let f = s.first else { return s }
		if vowels.contains(character: f) { return "an " + s}
		return "a " + s
	}
	private static func addComma(_ s: String) -> String {
		guard let l = s.last else { return s + "," }
		switch l {
		case ",", ".", "?", "!":
			return s
		default:
			return s + ","
		}
	}
	private static func cap(_ s: String) -> String {
		let words = s.split { $0 == " " }
		guard let first = words.first else { return s }
		return ([first.capitalized] + words.dropFirst().map { String($0) }).joined(separator: " ")
	}
	
	private static func endsWithConsonantY(_ s: String) -> Bool {
		guard let last = s.last else { return false }
		if last != "y" { return false }
		guard let secondLast = s.dropLast().last else { return false }
		return !vowels.contains(character: secondLast)
	}
	private static func makePastTense(_ s: String) -> String {
		let words = s.split(separator: " ")
		guard var firstWord = words.first else { return s }
		guard let l = firstWord.last else { return s }
		switch l {
		case "y":
			guard let secondLast = s.dropLast().last else { return s }
			if vowels.contains(character: secondLast) { return s + "ed" }
			firstWord = firstWord.dropLast() + "ied"
		case "e":
			firstWord = firstWord + "d"
		default:
			firstWord = firstWord + "ed"
		}
		return (([firstWord] + words.dropFirst()).map { String($0) }).joined(separator: " ")
	}
	private static let vowels = CharacterSet(charactersIn: "aeiouAEIOU")
}

extension CharacterSet {
	func contains(character: Character) -> Bool {
		let set = CharacterSet(charactersIn: String(character))
		return set.isStrictSubset(of: self)
	}
}


