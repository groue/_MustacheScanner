/**
 The type for expressions that appear in tags: `name`, `user.name`,
 `uppercase(user.name)`, etc.
 */
public enum Expression {
    
    // {{ . }}
    case ImplicitIterator
    
    // {{ identifier }}
    case Identifier(identifier: String)
    
    // {{ <expression>.identifier }}
    indirect case Scoped(baseExpression: Expression, identifier: String)
    
    // {{ <expression>(<expression>) }}
    indirect case Filter(filterExpression: Expression, argumentExpression: Expression, partialApplication: Bool)
}

/**
 Expression conforms to Equatable so that the Compiler can check that section
 tags have matching openings and closings: {{# person }}...{{/ person }} is OK
 but {{# foo }}...{{/ bar }} is not.
 */
extension Expression: Equatable {
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
    case (.ImplicitIterator, .ImplicitIterator):
        return true
        
    case (.Identifier(let lIdentifier), .Identifier(let rIdentifier)):
        return lIdentifier == rIdentifier
        
    case (.Scoped(let lBase, let lIdentifier), .Scoped(let rBase, let rIdentifier)):
        return lBase == rBase && lIdentifier == rIdentifier
        
    case (.Filter(let lFilter, let lArgument, let lPartialApplication), .Filter(let rFilter, let rArgument, let rPartialApplication)):
        return lFilter == rFilter && lArgument == rArgument && lPartialApplication == rPartialApplication
        
    default:
        return false
    }
}
