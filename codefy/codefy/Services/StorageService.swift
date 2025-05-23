import Foundation
import FirebaseStorage

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()
    
    private init() {}
    
    func uploadData(_ data: Data, path: String, contentType: String = "image/jpeg") async throws -> URL {
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL
    }
    
    func deleteFile(at path: String) async throws {
        let storageRef = storage.reference().child(path)
        try await storageRef.delete()
    }
    
    func getDownloadURL(for path: String) async throws -> URL {
        let storageRef = storage.reference().child(path)
        return try await storageRef.downloadURL()
    }
} 