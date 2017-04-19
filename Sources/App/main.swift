import Vapor
import VaporPostgreSQL
import HTTP


let drop = Droplet()
do {
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}
drop.preparations += Word.self
drop.preparations += Definition.self

// test the connection of database
drop.get("version") { req in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "No db connection"
    }
    
}

//Redirect to word
drop.get() { req in
    
    // change to your URL
    return Response(redirect: req.uri.appendingPathComponent("word").path)
}

// Show all the words
drop.get("word") { req in
    return try JSON(node: Word.all().makeNode())
}

// Show single word
drop.get("word", String.self) { req, wordString in
    
    // Check if the word exist
    if let word = try Word.query().filter("word", wordString).first() {
        
        // if exist, show all the definition
        return try JSON(node: word.definitions().all().makeNode())
        
    } else {
        
        // create a new word and save
        var word = Word(word: wordString)
        try word.save()
        
        let wordDictResponse = try drop.client.get("https://owlbot.info/api/v1/dictionary/\(wordString)")
        
        print(wordDictResponse.json?.array ?? "no response")
        
        if let jsonArray = wordDictResponse.json?.array {
            
            for jsonDict in jsonArray {
                print(jsonDict)
                if let jsonDefinition = jsonDict as? JSON {
                    let definition = jsonDefinition["defenition"]?.string ?? "no definition"
                    let example = jsonDefinition["example"]?.string ?? " "
                    let type = jsonDefinition["type"]?.string ?? "no type"
                    
                    //create Definition
                    var newDefinition = Definition(word_id: word.id!, definition: definition, example: example, type: type)
                    try! newDefinition.save()
                }
                
            }
        }
        
        return try JSON(node: word.definitions().all().makeNode())
        
    }
    
}


drop.run()
