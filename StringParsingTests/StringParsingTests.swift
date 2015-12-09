//
//  StringParsingTests.swift
//  StringParsingTests
//
//  Created by Gwendal Roué on 09/12/2015.
//  Copyright © 2015 Pierlis. All rights reserved.
//

import XCTest
@testable import StringParsing

class StringParsingTests: XCTestCase {
    
    func testParsing(string: String, tagEndDelimiter: String, expectedExpression: Expression, expectedDistance: Scanner.Distance) {
        print(String(reflecting: string))
        let scanner = Scanner(characters: string.characters)
        let expressionParser = ExpressionParser()
        var empty = false
        do {
            let expression = try expressionParser.parseExpression(scanner, tagEndDelimiter: tagEndDelimiter, empty: &empty)
            XCTAssertEqual(expression, expectedExpression)
            XCTAssertEqual(scanner.characters.startIndex.distanceTo(scanner.scanIndex), expectedDistance)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testParsing(string: String, tagEndDelimiter: String, expectedEmpty: Bool,  expectedError: String, expectedDistance: Scanner.Distance) {
        print(String(reflecting: string))
        let scanner = Scanner(characters: string.characters)
        let expressionParser = ExpressionParser()
        var empty = false
        do {
            try expressionParser.parseExpression(scanner, tagEndDelimiter: tagEndDelimiter, empty: &empty)
            XCTFail("Expected error: \(expectedError)")
        } catch {
            XCTAssertEqual("\(error)", expectedError)
            XCTAssertEqual(empty, expectedEmpty)
            XCTAssertEqual(scanner.characters.startIndex.distanceTo(scanner.scanIndex), expectedDistance)
        }
    }
    
    func testExpressionString(string: String, expectedExpression: Expression) {
        let length = string.characters.count
        testParsing(" \(string)", tagEndDelimiter: "}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 0)
        testParsing("\(string)", tagEndDelimiter: "}}", expectedExpression: expectedExpression, expectedDistance: length)
        testParsing("\(string) ", tagEndDelimiter: "}}", expectedExpression: expectedExpression, expectedDistance: length)
        testParsing("\(string) extra", tagEndDelimiter: "}}", expectedExpression: expectedExpression, expectedDistance: length)
        testParsing("\(string)\r\n", tagEndDelimiter: "}}", expectedExpression: expectedExpression, expectedDistance: length)
        testParsing("\(string)}}", tagEndDelimiter: "}}", expectedExpression: expectedExpression, expectedDistance: length)
        testParsing("\(string) }}", tagEndDelimiter: "}}", expectedExpression: expectedExpression, expectedDistance: length)
        testParsing("\(string)\r\n}}", tagEndDelimiter: "}}", expectedExpression: expectedExpression, expectedDistance: length)
    }
    
    func testExpressionParsing() {
        testParsing("", tagEndDelimiter: "}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 0)
        testParsing(" ", tagEndDelimiter: "}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 0)
        testParsing("\r\n", tagEndDelimiter: "}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 0)
        testParsing("}}", tagEndDelimiter: "}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 0)
        testParsing(" }}", tagEndDelimiter: "}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 0)
        testParsing("\r\n}}", tagEndDelimiter: "}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 0)
        
        testExpressionString(".", expectedExpression: Expression.ImplicitIterator)
        testExpressionString("a", expectedExpression: Expression.Identifier(identifier: "a"))
        testExpressionString("foo?", expectedExpression: Expression.Identifier(identifier: "foo?"))
        testExpressionString(".a", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"))
        testExpressionString(".a.foo!", expectedExpression: Expression.Scoped(baseExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"), identifier: "foo!"))
        testExpressionString("a.b", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "a"), identifier: "b"))
        testExpressionString("f(x)", expectedExpression: Expression.Filter(filterExpression: Expression.Identifier(identifier: "f"), argumentExpression: Expression.Identifier(identifier: "x"), partialApplication: false))
        testExpressionString("f(x, y)", expectedExpression: Expression.Filter(filterExpression: Expression.Filter(filterExpression: Expression.Identifier(identifier: "f"), argumentExpression: Expression.Identifier(identifier: "x"), partialApplication: true), argumentExpression: Expression.Identifier(identifier: "y"), partialApplication: false))
        testExpressionString("f ( x(foo.bar) , y)", expectedExpression: Expression.Filter(filterExpression: Expression.Filter(filterExpression: Expression.Identifier(identifier: "f"), argumentExpression: Expression.Filter(filterExpression: Expression.Identifier(identifier: "x"), argumentExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "foo"), identifier: "bar"), partialApplication: false), partialApplication: true), argumentExpression: Expression.Identifier(identifier: "y"), partialApplication: false))
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
