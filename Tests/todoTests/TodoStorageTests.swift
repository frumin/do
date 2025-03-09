import XCTest
@testable import todo

final class TodoStorageTests: XCTestCase {
    var tempURL: URL!
    var storage: TodoStorage!
    
    override func setUp() {
        super.setUp()
        tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("txt")
        storage = TodoStorage(filePath: tempURL)
    }
    
    override func tearDown() {
        try? storage.deleteTodoFile()
        super.tearDown()
    }
    
    func testEmptyStorageReturnsEmptyArray() throws {
        let todos = try storage.readTodos()
        XCTAssertTrue(todos.isEmpty)
    }
    
    func testWriteAndReadTodos() throws {
        let testTodos = ["Buy milk", "Walk the dog", "Write tests"]
        try storage.writeTodos(testTodos)
        
        let readTodos = try storage.readTodos()
        XCTAssertEqual(readTodos, testTodos)
    }
    
    func testWriteEmptyArrayClearsTodos() throws {
        // First write some todos
        try storage.writeTodos(["Test todo"])
        
        // Then write an empty array
        try storage.writeTodos([])
        
        let todos = try storage.readTodos()
        XCTAssertTrue(todos.isEmpty)
    }
} 