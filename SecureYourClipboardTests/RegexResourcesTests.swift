//
//  RegexResourcesTests.swift
//  SecureYourClipboardTests
//
//  Created by lixindong on 2024/4/1.
//

import XCTest

final class RegexResourcesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testResources() async {
        let resources = await SwitchItemProvider.loadFromAssets()
        resources.forEach { model in
            print(model)
            model.example.forEach { example in
                print(example.input, example.output)
                let result = model.filter(example.input) { _ in
                    "<REPLACED>"
                }
                XCTAssertEqual(result, example.output, "filter failed with \(example.input) -> \(result) != \(example.output)")
            }
        }
    }
}
