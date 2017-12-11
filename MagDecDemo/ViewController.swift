
import UIKit


class ViewController: UIViewController  {
    
    let urlString: String = "https://magdecazex1.azurewebsites.net/dec"
    
    var masterDecInfo = DecInfo( dec: 0.0, lat: 0.0, lon: 0.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  let compositeUrl = NSURLComponents(string: urlString)
        
        let lat = 37.6;
        let lon = -111.1
        
        // local storage
        let defaults = UserDefaults.standard
        
        if let storedDecData = defaults.value(forKey:"decData") as? Data {
            
            let retrievedDecData = try! PropertyListDecoder().decode(DecInfo.self, from: storedDecData)
            
            print("retrievedDecData: \(retrievedDecData)")
            
            // TODO - Compare retrieved lat/lon to current lat/lon via Haversine Distance to
            // see if a new value needs to be gotten from the Magnetic Declination service.
            let distance = haversineDistance(lat1: lat, lon1: lon, lat2: retrievedDecData.lat, lon2: retrievedDecData.lon)
            
            print("distance: \(distance)")
            if(distance > 55000)
            {
                let dData = GetDecData()
                
                dData.GetDecDataFromSvc(urlString: urlString, lat: lat, lon: lon){
                    
                    decData in
                    
                    print("dd: \(decData)")
                    
                    self.masterDecInfo = decData
                    
                    print("mdi: \(self.masterDecInfo)")
                    
                    defaults.set(try? PropertyListEncoder().encode(decData), forKey: "decData")
                }
            }
        }
        else {
            
            let dData = GetDecData()
            
            dData.GetDecDataFromSvc(urlString: urlString, lat: lat, lon: lon){
                
                decData in
                
                print("dd: \(decData)")
                
                self.masterDecInfo = decData
                
                print("mdi: \(self.masterDecInfo)")
                
                defaults.set(try? PropertyListEncoder().encode(decData), forKey: "decData")
            }
        }
        
        

        
        // Want to get rid of this
        //        let params = [NSURLQueryItem(name: "lat", value: "\(lat)" ), NSURLQueryItem(name: "lon", value: "\(lon)" )]
        //
        //        compositeUrl?.queryItems = params as [URLQueryItem]
        //
        //        guard let url = compositeUrl?.url else { return }
        //
        //        URLSession.shared.dataTask(with: url) { (data, response, error) in
        //            if error != nil {
        //                print(error!.localizedDescription)
        //            }
        //
        //            guard let data = data else { return }
        //
        //            let decData = DecInfo.from(data: data)!
        //
        //            DispatchQueue.main.async {
        //                print(decData)
        //
        //                // local storage
        //                let defaults = UserDefaults.standard
        //
        //                defaults.set(try? PropertyListEncoder().encode(decData), forKey: "decData")
        //
        //                if let storedDecData = defaults.value(forKey:"decData") as? Data {
        //
        //                    let retrievedDecData = try! PropertyListDecoder().decode(DecInfo.self, from: storedDecData)
        //
        //                    print(retrievedDecData)
        //
        //                    // TODO - Compare retrieved lat/lon to current lat/lon via Haversine Distance to
        //                    // see if a new value needs to be gotten from the Magnetic Declination service.
        //                }
        //            }
        //
        //            }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


/* NOTE: This needs to be refactored and restructured so that a local/Haversine check is made first. A call to the magdecsv should
 only be made if either:
 
 1) There is no value stored locally
 2) The local value is invalid (determined after checking distance from current location to stored location - threshold exceeded)
 
 */
class GetDecData{
    
    
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
