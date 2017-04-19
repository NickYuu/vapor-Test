import Vapor
import Fluent
import Foundation

final class Word: Model {
    var id: Node?
    var exists: Bool = false
    
    var word: String
    
    
    init(word: String) {
        self.id = nil
        self.word = word
        
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        word = try node.extract("word")
        
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "word": word,
            ])
    }
}

extension Word: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("words", closure: { words in
            words.id()
            words.string("word")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("words")
    }
}

extension Word {
    func definitions() throws -> Children<Definition> {
        return children()
    }
}
