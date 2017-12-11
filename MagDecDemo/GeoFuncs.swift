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
