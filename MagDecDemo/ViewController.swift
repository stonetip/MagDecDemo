
import UIKit


class ViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CheckDecData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



func CheckDecData()
{
    
    let urlString: String = "https://magdecazex1.azurewebsites.net/dec"
    
    let lat = 37.6;
    let lon = -111.1
    
    var distance = 0.0;
    
    if let storedDecData = UserDefaults.standard.value(forKey:"decData") as? Data {
        
        let retrievedDecData = try! PropertyListDecoder().decode(DecInfo.self, from: storedDecData)
        
        print("retrievedDecData: \(retrievedDecData)")
        
        // Compare retrieved lat/lon to current lat/lon via Haversine Distance to see
        // if a new value needs to be gotten from the Magnetic Declination service.
        distance = haversineDistance(lat1: lat, lon1: lon, lat2: retrievedDecData.lat, lon2: retrievedDecData.lon)
        
        print("distance: \(distance)")
        
        if(distance < 55000){
            return
        }
    }
    
    let decDataSvc = DecDataSvc()
    
    decDataSvc.GetDecDataFromSvc(urlString: urlString, lat: lat, lon: lon){ decData in
        
        print("from svc: \(decData)")
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(decData), forKey: "decData")
    }
    
}


class DecDataSvc{
    
    
    func GetDecDataFromSvc(urlString: String, lat: Double, lon: Double, completion: @escaping (DecInfo) -> ()) {
        
        var decData = DecInfo( dec: 0.0, lat: 0.0, lon: 0.0)
        
        let compositeUrl = NSURLComponents(string: urlString)
        
        let params = [NSURLQueryItem(name: "lat", value: "\(lat)" ), NSURLQueryItem(name: "lon", value: "\(lon)" )]
        
        compositeUrl?.queryItems = params as [URLQueryItem]
        
        guard let url = compositeUrl?.url else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            decData = DecInfo.from(data: data)!
            
            completion(decData)
            
            }.resume()
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
