import Vapor
import Fluent
import Foundation

final class Definition: Model {
    var id: Node?
    var exists: Bool = false
    
    var word_id: Node?
    var definition: String
    var example: String
    var type: String
    
    init(word_id: Node,definition: String, example: String, type: String) {
        self.id = nil
        self.word_id = word_id
        self.definition = definition
        self.example = example
        self.type = type
        
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        word_id = try node.extract("word_id")
        definition = try node.extract("definition")
        example = try node.extract("example")
        type = try node.extract("type")
        
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "word_id": word_id,
            "definition": definition,
            "example": example,
            "type": type,
            ])
    }
}

extension Definition: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("definitions", closure: { definitions in
            definitions.id()
            definitions.parent(Word.self, optional: false, unique: false, default: nil)
            definitions.string("definition")
            definitions.string("example")
            definitions.string("type")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("definitions")
    }
}

extension Definition {
    func word() throws -> Parent<Word> {
        return try parent(word_id)
    }
}
