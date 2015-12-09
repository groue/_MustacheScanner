public class ExpressionParser {
    var scanner: Scanner
    
    init(scanner: Scanner) {
        self.scanner = scanner
    }
    
    func parseExpression(inout outEmpty: Bool) throws -> Expression {
    
        enum State {
            // error
            case Error(String)
            
            // Any expression can start
            case WaitingForAnyExpression
            
            // Expression has started with a dot
            case LeadingDot
            
            // Expression has started with an identifier
            case Identifier(identifierStart: Scanner.Index)
            
            // Parsing a scoping identifier
            case ScopingIdentifier(identifierStart: Scanner.Index, baseExpression: Expression)
            
            // Waiting for a scoping identifier
            case WaitingForScopingIdentifier(baseExpression: Expression)
            
            // Parsed an expression
            case DoneExpression(expression: Expression)
            
            // Parsed white space after an expression
            case DoneExpressionPlusWhiteSpace(expression: Expression)
        }
        
        var state: State = .WaitingForAnyExpression
        var filterExpressionStack: [Expression] = []
        let initialIndex = scanner.scanIndex
        
        characterLoop: while let c = scanner.scanCharacter() {
            
            switch state {
            case .Error:
                break characterLoop
                
            case .WaitingForAnyExpression:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    state = .LeadingDot
                case "(", ")", ",", "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                default:
                    state = .Identifier(identifierStart: scanner.scanIndex.predecessor())
                }
                
            case .LeadingDot:
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .DoneExpressionPlusWhiteSpace(expression: Expression.ImplicitIterator)
                case ".":
                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                case "(":
                    filterExpressionStack.append(Expression.ImplicitIterator)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.ImplicitIterator, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.ImplicitIterator, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    scanner.advanceBy(-1)
                    break characterLoop
//                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                default:
                    state = .ScopingIdentifier(identifierStart: scanner.scanIndex.predecessor(), baseExpression: Expression.ImplicitIterator)
                }
                
            case .Identifier(identifierStart: let identifierStart):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                    state = .DoneExpressionPlusWhiteSpace(expression: Expression.Identifier(identifier: identifier))
                case ".":
                    let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                    state = .WaitingForScopingIdentifier(baseExpression: Expression.Identifier(identifier: identifier))
                case "(":
                    let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                    filterExpressionStack.append(Expression.Identifier(identifier: identifier))
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.Identifier(identifier: identifier), partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: Expression.Identifier(identifier: identifier), partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                default:
                    break
                }
                
            case .ScopingIdentifier(identifierStart: let identifierStart, baseExpression: let baseExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                    let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                    state = .DoneExpressionPlusWhiteSpace(expression: scopedExpression)
                case ".":
                    let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                    let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                    state = .WaitingForScopingIdentifier(baseExpression: scopedExpression)
                case "(":
                    let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                    let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                    filterExpressionStack.append(scopedExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                        let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: scopedExpression, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let identifier = String(scanner.characters[identifierStart..<scanner.scanIndex.predecessor()])
                        let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: scopedExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                default:
                    break
                }
                
            case .WaitingForScopingIdentifier(let baseExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .Error("Unexpected white space character at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                case ".":
                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                case "(":
                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                case ")":
                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                case ",":
                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                case "{", "}", "&", "$", "#", "^", "/", "<", ">":
                    state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                default:
                    state = .ScopingIdentifier(identifierStart: scanner.scanIndex.predecessor(), baseExpression: baseExpression)
                }
                
            case .DoneExpression(let doneExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    state = .DoneExpressionPlusWhiteSpace(expression: doneExpression)
                case ".":
                    state = .WaitingForScopingIdentifier(baseExpression: doneExpression)
                case "(":
                    filterExpressionStack.append(doneExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                case ",":
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        state = .Error("Unexpected character `\(c)` at index \(scanner.characters.startIndex.distanceTo(scanner.scanIndex.predecessor()))")
                    }
                default:
                    scanner.advanceBy(-1)
                    break characterLoop
                }
                
            case .DoneExpressionPlusWhiteSpace(let doneExpression):
                switch c {
                case " ", "\r", "\n", "\r\n", "\t":
                    break
                case ".":
                    scanner.advanceBy(-1)
                    break characterLoop
                case "(":
                    // Accept "a (b)"
                    filterExpressionStack.append(doneExpression)
                    state = .WaitingForAnyExpression
                case ")":
                    // Accept "a(b )"
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        let expression = Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: false)
                        state = .DoneExpression(expression: expression)
                    } else {
                        scanner.advanceBy(-1)
                        break characterLoop
                    }
                case ",":
                    // Accept "a(b ,c)"
                    if let filterExpression = filterExpressionStack.last {
                        filterExpressionStack.removeLast()
                        filterExpressionStack.append(Expression.Filter(filterExpression: filterExpression, argumentExpression: doneExpression, partialApplication: true))
                        state = .WaitingForAnyExpression
                    } else {
                        scanner.advanceBy(-1)
                        break characterLoop
                    }
                default:
                    scanner.advanceBy(-1)
                    break characterLoop
                }
            }
        }
        
        
        // Parsing done
        
        enum FinalState {
            case Error(String)
            case Empty
            case Valid(expression: Expression)
        }
        
        let finalState: FinalState
        
        switch state {
        case .WaitingForAnyExpression:
            if filterExpressionStack.isEmpty {
                finalState = .Empty
            } else {
                finalState = .Error("Missing `)` character at index \(scanner.characters.startIndex.distanceTo(scanner.characters.endIndex))")
            }
            
        case .LeadingDot:
            if filterExpressionStack.isEmpty {
                finalState = .Valid(expression: Expression.ImplicitIterator)
            } else {
                finalState = .Error("Missing `)` character at index \(scanner.characters.startIndex.distanceTo(scanner.characters.endIndex))")
            }
            
        case .Identifier(identifierStart: let identifierStart):
            if filterExpressionStack.isEmpty {
                let identifier = String(scanner.characters[identifierStart..<scanner.characters.endIndex])
                finalState = .Valid(expression: Expression.Identifier(identifier: identifier))
            } else {
                finalState = .Error("Missing `)` character at index \(scanner.characters.startIndex.distanceTo(scanner.characters.endIndex))")
            }
            
        case .ScopingIdentifier(identifierStart: let identifierStart, baseExpression: let baseExpression):
            if filterExpressionStack.isEmpty {
                let identifier = String(scanner.characters[identifierStart..<scanner.characters.endIndex])
                let scopedExpression = Expression.Scoped(baseExpression: baseExpression, identifier: identifier)
                finalState = .Valid(expression: scopedExpression)
            } else {
                finalState = .Error("Missing `)` character at index \(scanner.characters.startIndex.distanceTo(scanner.characters.endIndex))")
            }
            
        case .WaitingForScopingIdentifier:
            finalState = .Error("Missing identifier at index \(scanner.characters.startIndex.distanceTo(scanner.characters.endIndex))")
            
        case .DoneExpression(let doneExpression):
            if filterExpressionStack.isEmpty {
                finalState = .Valid(expression: doneExpression)
            } else {
                finalState = .Error("Missing `)` character at index \(scanner.characters.startIndex.distanceTo(scanner.characters.endIndex))")
            }
            
        case .DoneExpressionPlusWhiteSpace(let doneExpression):
            if filterExpressionStack.isEmpty {
                finalState = .Valid(expression: doneExpression)
            } else {
                finalState = .Error("Missing `)` character at index \(scanner.characters.startIndex.distanceTo(scanner.characters.endIndex))")
            }
            
        case .Error(let message):
            finalState = .Error(message)
        }
        
        
        // End
        
        switch finalState {
        case .Empty:
            outEmpty = true
            throw MustacheError(kind: .ParseError, message: "Missing expression")
            
        case .Error(let description):
            outEmpty = false
            let expressionString = String(scanner.characters[initialIndex..<scanner.scanIndex])
            throw MustacheError(kind: .ParseError, message: "Invalid expression `\(expressionString)`: \(description)")
            
        case .Valid(expression: let expression):
            return expression
        }
    }
}