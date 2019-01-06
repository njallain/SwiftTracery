//
//  MockGenerator.swift
//  SwiftTraceryTests
//
//  Created by Neil Allain on 1/6/19.
//  Copyright © 2019 Neil Allain. All rights reserved.
//

import Foundation
@testable import SwiftTracery

class MockGenerator: FragmentGenerator {
	func randomFragment(_ fragments: Array<Fragment>) -> Fragment?  {
		return fragments[index]
	}
	
	var index = 0
	
}
