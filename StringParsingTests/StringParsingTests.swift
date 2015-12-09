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
    
    func testParsing(string: String, expectedExpression: Expression, expectedDistance: Scanner.Distance) {
        let scanner = Scanner(characters: string.characters)
        let expressionParser = ExpressionParser(scanner: scanner)
        var empty = false
        do {
            let expression = try expressionParser.parseExpression(&empty)
            print(string)
            XCTAssertEqual(expression, expectedExpression)
            XCTAssertEqual(scanner.characters.startIndex.distanceTo(scanner.scanIndex), expectedDistance)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testParsing(string: String, expectedEmpty: Bool,  expectedError: String, expectedDistance: Scanner.Distance) {
        let scanner = Scanner(characters: string.characters)
        let expressionParser = ExpressionParser(scanner: scanner)
        var empty = false
        do {
            try expressionParser.parseExpression(&empty)
            print(string)
            XCTFail("Expected error: \(expectedError)")
        } catch {
            XCTAssertEqual("\(error)", expectedError)
            XCTAssertEqual(empty, expectedEmpty)
        }
    }
    
    func testExpressionParsing() {
        testParsing("", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 1)
        testParsing(" ", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 1)
        testParsing("\r\n", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 1)
        testParsing("}}", expectedEmpty: true, expectedError: "Parse error: Invalid expression", expectedDistance: 1)
        testParsing(" }}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 1)
        testParsing("\r\n}}", expectedEmpty: true, expectedError: "Parse error: Missing expression", expectedDistance: 1)

        testParsing(".", expectedExpression: Expression.ImplicitIterator, expectedDistance: 1)
        testParsing(". ", expectedExpression: Expression.ImplicitIterator, expectedDistance: 2)
        testParsing(".\r\n", expectedExpression: Expression.ImplicitIterator, expectedDistance: 2)
//        testParsing(".}}", expectedExpression: Expression.ImplicitIterator, expectedDistance: 1)
        testParsing(". }}", expectedExpression: Expression.ImplicitIterator, expectedDistance: 2)
        testParsing(".\r\n}}", expectedExpression: Expression.ImplicitIterator, expectedDistance: 2)
        
        testParsing("a", expectedExpression: Expression.Identifier(identifier: "a"), expectedDistance: 1)
        testParsing("a ", expectedExpression: Expression.Identifier(identifier: "a"), expectedDistance: 2)
        testParsing("a\r\n", expectedExpression: Expression.Identifier(identifier: "a"), expectedDistance: 2)
//        testParsing("a}}", expectedExpression: Expression.Identifier(identifier: "a"), expectedDistance: 1)
        testParsing("a }}", expectedExpression: Expression.Identifier(identifier: "a"), expectedDistance: 2)
        testParsing("a\r\n}}", expectedExpression: Expression.Identifier(identifier: "a"), expectedDistance: 2)
        
        testParsing("foo", expectedExpression: Expression.Identifier(identifier: "foo"), expectedDistance: 3)
        testParsing("foo ", expectedExpression: Expression.Identifier(identifier: "foo"), expectedDistance: 4)
        testParsing("foo\r\n", expectedExpression: Expression.Identifier(identifier: "foo"), expectedDistance: 4)
//        testParsing("foo}}", expectedExpression: Expression.Identifier(identifier: "foo"), expectedDistance: 3)
        testParsing("foo }}", expectedExpression: Expression.Identifier(identifier: "foo"), expectedDistance: 4)
        testParsing("foo\r\n}}", expectedExpression: Expression.Identifier(identifier: "foo"), expectedDistance: 4)
        
        testParsing(".a", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"), expectedDistance: 2)
        testParsing(".a ", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"), expectedDistance: 3)
        testParsing(".a\r\n", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"), expectedDistance: 3)
//        testParsing(".a}}", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"), expectedDistance: 2)
        testParsing(".a }}", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"), expectedDistance: 3)
        testParsing(".a\r\n}}", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "a"), expectedDistance: 3)
        
        testParsing(".foo", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "foo"), expectedDistance: 4)
        testParsing(".foo ", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "foo"), expectedDistance: 5)
        testParsing(".foo\r\n", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "foo"), expectedDistance: 5)
//        testParsing(".foo}}", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "foo"), expectedDistance: 4)
        testParsing(".foo }}", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "foo"), expectedDistance: 5)
        testParsing(".foo\r\n}}", expectedExpression: Expression.Scoped(baseExpression: Expression.ImplicitIterator, identifier: "foo"), expectedDistance: 5)
        
        testParsing("a.a", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "a"), identifier: "a"), expectedDistance: 3)
        testParsing("a.a ", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "a"), identifier: "a"), expectedDistance: 4)
        testParsing("a.a\r\n", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "a"), identifier: "a"), expectedDistance: 4)
//        testParsing("a.a}}", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "a"), identifier: "a"), expectedDistance: 3)
        testParsing("a.a }}", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "a"), identifier: "a"), expectedDistance: 4)
        testParsing("a.a\r\n}}", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "a"), identifier: "a"), expectedDistance: 4)
        
        testParsing("foo.a", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "foo"), identifier: "a"), expectedDistance: 5)
        testParsing("foo.a ", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "foo"), identifier: "a"), expectedDistance: 6)
        testParsing("foo.a\r\n", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "foo"), identifier: "a"), expectedDistance: 6)
//        testParsing("foo.a}}", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "foo"), identifier: "a"), expectedDistance: 5)
        testParsing("foo.a }}", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "foo"), identifier: "a"), expectedDistance: 6)
        testParsing("foo.a\r\n}}", expectedExpression: Expression.Scoped(baseExpression: Expression.Identifier(identifier: "foo"), identifier: "a"), expectedDistance: 6)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
