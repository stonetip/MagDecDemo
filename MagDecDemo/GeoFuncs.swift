//
//  GeoFuncs.swift
//  MagDecDemo
//
//  Created by Jonathan Nehring on 12/11/17.
//  Copyright © 2017 Jonathan Nehring. All rights reserved.
//

import Foundation


func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    
    // Converts from degrees to radians
    let degToRad = { (degrees: Double) -> Double in
        return degrees * .pi / 180
    }
    
    let R: Double = 6371e3; // meters
    
    let lat1Rad: Double = degToRad(lat1);
    let lat2Rad: Double = degToRad(lat2);
    let deltaLat: Double = degToRad(lat2 - lat1);
    let deltaLon: Double = degToRad(lon2 - lon1);
    
    let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) *
        cos(lat2Rad) *
        sin(deltaLon / 2) *
        sin(deltaLon / 2)
    
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    
    return R * c
}



public func CheckDecData(lat: Double, lon: Double)
{
    if let storedDecData = UserDefaults.standard.value(forKey:"decData") as? Data {
        
        let retrievedDecData = try! PropertyListDecoder().decode(DecInfo.self, from: storedDecData)
        
        print("retrievedDecData: \(retrievedDecData)")
        
        // Compare retrieved lat/lon to current lat/lon via Haversine Distance to see
        // if a new value needs to be gotten from the Magnetic Declination service.
        let distance = haversineDistance(lat1: lat, lon1: lon, lat2: retrievedDecData.lat, lon2: retrievedDecData.lon)
        
        print("distance: \(distance)")
        
        if(distance < 55000){
            return
        }
    }
    
    let decDataSvc = DecDataSvc()
    
    decDataSvc.GetDecDataFromSvc(lat: lat, lon: lon){ decData in
        
        print("from svc: \(decData)")
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(decData), forKey: "decData")
    }
    
}


public class DecDataSvc{
    
    
    func GetDecDataFromSvc(lat: Double, lon: Double, completion: @escaping (DecInfo) -> ()) {
        
        // Get URL string key from plist
        let urlString:String = Bundle.main.object(forInfoDictionaryKey: "DeclinationSvcUrl") as! String
        
        print("urlString: \(urlString)")
        
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





