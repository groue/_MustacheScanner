public class Scanner {
    typealias Index = String.CharacterView.Index
    typealias Distance = String.CharacterView.Index.Distance
    let characters: String.CharacterView
    var scanIndex: Index
    private let endIndex: Index
    
    init(characters: String.CharacterView, initialIndex: Index? = nil) {
        self.characters = characters
        self.scanIndex = initialIndex ?? characters.startIndex
        self.endIndex = characters.endIndex
    }
    
    var atEnd: Bool {
        return scanIndex == endIndex
    }
    
    func scanCharacter() -> Character? {
        guard scanIndex < endIndex else {
            return nil
        }
        let result = self.characters[scanIndex]
        scanIndex = scanIndex.successor()
        return result
    }
    
    func scanString(string: String) -> String? {
        let stringCharacters = string.characters
        let stringLength = stringCharacters.count
        guard scanIndex.distanceTo(endIndex) >= stringLength else {
            return nil
        }
        let successEndIndex = scanIndex.advancedBy(stringLength)
        let nextCharacters = characters[scanIndex..<successEndIndex]
        for (nextCharacter, stringCharacter) in zip(nextCharacters, stringCharacters) {
            if nextCharacter != stringCharacter {
                return nil
            }
        }
        self.scanIndex = successEndIndex
        return string
    }
}
