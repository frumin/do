import XCTest
@testable import todo
import ArgumentParser

final class TodoCommandTests: XCTestCase {
    var tempURL: URL!
    
    override func setUp() {
        super.setUp()
        tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("txt")
        // Replace the default storage with our test storage
        Todo.storage = TodoStorage(filePath: tempURL)
    }
    
    override func tearDown() {
        try? Todo.storage.deleteTodoFile()
        super.tearDown()
    }
    
    func testAddCommand() throws {
        // Test adding a todo
        var add = AddCommand()
        add.item = ["Buy", "groceries"]
        try add.run()
        
        let todos = try Todo.storage.readTodos()
        XCTAssertEqual(todos, ["Buy groceries"])
    }
    
    func testListCommand() throws {
        // First add some todos
        try Todo.storage.writeTodos(["First todo", "Second todo"])
        
        // Create string output stream for capturing output
        var outputStream = StringOutputStream()
        
        // Run list command with our test output stream
        try ListCommand.listTodos(to: &outputStream)
        
        // Verify output
        XCTAssertEqual(outputStream.output, "1. First todo\n2. Second todo\n")
    }
    
    func testListEmptyTodos() throws {
        // Create string output stream for capturing output
        var outputStream = StringOutputStream()
        
        // Run list command with our test output stream
        try ListCommand.listTodos(to: &outputStream)
        
        // Verify output
        XCTAssertEqual(outputStream.output, "No todos yet!\n")
    }
    
    func testDoneCommand() throws {
        // First add some todos
        try Todo.storage.writeTodos(["First todo", "Second todo"])
        
        // Mark first todo as done
        var done = DoneCommand()
        done.number = 1
        try done.run()
        
        // Verify todo was removed
        let todos = try Todo.storage.readTodos()
        XCTAssertEqual(todos, ["Second todo"])
    }
    
    func testRemoveCommand() throws {
        // First add some todos
        try Todo.storage.writeTodos(["First todo", "Second todo"])
        
        // Remove second todo
        var remove = RemoveCommand()
        remove.number = 2
        try remove.run()
        
        // Verify todo was removed
        let todos = try Todo.storage.readTodos()
        XCTAssertEqual(todos, ["First todo"])
    }
    
    func testInvalidTodoNumber() throws {
        // First add a todo
        try Todo.storage.writeTodos(["Test todo"])
        
        // Try to remove invalid todo number
        var remove = RemoveCommand()
        remove.number = 2
        
        XCTAssertThrowsError(try remove.run()) { error in
            XCTAssertTrue(error is ValidationError)
            if let validationError = error as? ValidationError {
                XCTAssertEqual(validationError.message, "Invalid todo number")
            }
        }
    }
} 