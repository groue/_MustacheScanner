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
}
