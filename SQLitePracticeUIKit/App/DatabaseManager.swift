//
//  DatabaseManager.swift
//  SQLitePracticeUIKit
//
//  Created by Harsh on 17/03/26.
//

import Foundation
import GRDB

/// This class handles everything related to SQLite.
/// It's a "Manager" so that ViewControllers don't have to worry about SQL.
class DatabaseManager {
    
    // MARK: - Singleton
    
    /// 'shared' is a Singleton instance.
    /// It ensures that only ONE connection to the database exists at a time.
    static let shared = DatabaseManager()
    
    // MARK: - Properties
    
    /// DatabaseQueue is the safe way to talk to SQLite using GRDB.
    /// We make it optional because database setup might fail (rarely).
    var dbQueue: DatabaseQueue?
    
    // MARK: - Initializer
    
    /// 'private init' prevents other classes from creating their own DatabaseManager.
    /// This keeps our data safe and consistent.
    private init() {
        setupDatabase()
    }
    
    // MARK: - Setup Methods
    
    /// This function finds the file path and creates the 'users' table.
    private func setupDatabase() {
        do {
            // 1. Find the "Documents" folder on the iPhone
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            // 2. Define the name for our database file
            let databaseURL = documentsURL.appendingPathComponent("db.sqlite")
            
            // Print the path so we can find the file on our Mac for debugging
            print("DEBUG 📁: Database location -> \(databaseURL.path)")
            
            // 3. Initialize the Database Queue with the file path
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            
            // 4. Create the 'users' table if it doesn't exist yet
            try createTables()
            
            print("DEBUG ✅: Database setup complete.")
            
        } catch {
            // If something goes wrong, we print a readable error message
            print("❌ DATABASE MANAGER ERROR: \(error.localizedDescription)")
        }
    }
    
    /// Creates the necessary tables inside the SQLite file.
    private func createTables() throws {
        // We use 'write' because we are changing the database structure
        try dbQueue?.write { db in
            
            // We create a table named "users"
            try db.create(table: User.databaseTableName, ifNotExists: true) { table in
                
                // 'id' is our primary key. SQLite will auto-increment it (1, 2, 3...)
                table.autoIncrementedPrimaryKey("id")
                
                // 'name' column: must be Text and cannot be empty (notNull)
                table.column("name", .text).notNull()
                
                // 'age' column: must be an Integer
                table.column("age", .integer).notNull()
                
                // 'profileImageData' column: stores binary data (images)
                table.column("profileImageData", .blob)
            }
        }
        print("DEBUG 🛠️: 'users' table is ready.")
    }
}
