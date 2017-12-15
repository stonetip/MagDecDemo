import Foundation

public struct DecInfo: Codable {
    let dec: Double
    let lat: Double
    let lon: Double
}

// MARK: Top-level extensions -

public extension DecInfo {
    static func from(json: String, using encoding: String.Encoding = .utf8) -> DecInfo? {
        guard let data = json.data(using: encoding) else { return nil }
        return from(data: data)
    }
    
    static func from(data: Data) -> DecInfo? {
        let decoder = JSONDecoder()
        return try? decoder.decode(DecInfo.self, from: data)
    }

    var jsonData: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    var jsonString: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: Codable extensions -

public extension DecInfo {
    enum CodingKeys: String, CodingKey {
        case dec = "dec"
        case lat = "lat"
        case lon = "lon"
    }
}
