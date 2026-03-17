//
//  User.swift
//  SQLitePracticeUIKit
//
//  Created by Harsh on 17/03/26.
//

import Foundation
import UIKit
import GRDB

// MARK: - User Model
struct User: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var name: String
    var age: Int
    var profileImageData: Data?
    
    static let databaseTableName = "users"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let age = Column(CodingKeys.age)
        static let profileImageData = Column(CodingKeys.profileImageData)
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
        print("DEBUG: User inserted with ID: \(inserted.rowID)")
    }
    
    // MARK: - Compression Helper
    /// Compresses UIImage to 10% (0.1) quality to save space in SQLite
    static func compressImage(_ image: UIImage) -> Data? {
        // compressionQuality: 1.0 is max, 0.0 is min.
        // We are using 0.1 as per your requirement.
        let compressedData = image.jpegData(compressionQuality: 0.1)
        
        // Debug: Print size difference
        if let data = compressedData {
            let sizeInKB = Double(data.count) / 1024.0
            print("DEBUG 📉: Image compressed to \(String(format: "%.2f", sizeInKB)) KB")
        }
        
        return compressedData
    }
}
