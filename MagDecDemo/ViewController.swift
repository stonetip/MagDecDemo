
import UIKit




class ViewController: UIViewController  {
    
    
    
    let urlString: String = "https://magdecazex1.azurewebsites.net/dec"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let compositeUrl = NSURLComponents(string: urlString)
        
        let lat = 46.6;
        let lon = -112.1
        
        let params = [NSURLQueryItem(name: "lat", value: "\(lat)" ), NSURLQueryItem(name: "lon", value: "\(lon)" )]
        
        compositeUrl?.queryItems = params as [URLQueryItem]
        
        guard let url = compositeUrl?.url else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
            
                guard let data = data else { return }

                let decData = DecInfo.from(data: data)!

                DispatchQueue.main.async {
                    print(decData)
                }
            
            }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}








struct DecInfo: Codable {
    let dec: Double
    let lat: Double
    let lon: Double
}

// MARK: Top-level extensions -

extension DecInfo {
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

extension DecInfo {
    enum CodingKeys: String, CodingKey {
        case dec = "dec"
        case lat = "lat"
        case lon = "lon"
    }
}
