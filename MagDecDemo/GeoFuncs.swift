//
//  GeoFuncs.swift
//  MagDecDemo
//
//  Created by Jonathan Nehring on 12/11/17.
//  Copyright © 2017 Jonathan Nehring. All rights reserved.
//

import Foundation

/**
 - Parameters:
 - cubes: The cubes available for allocation
 - people: The people that require cubes
 */
func haversineDistance(la1: Double, lo1: Double, la2: Double, lo2: Double) -> Double {
    
    let radius: Double = 6367444.7
    
    let haversine = { (angle: Double) -> Double in
        return (1 - cos(angle))/2
    }
    
    let ahaversine = { (angle: Double) -> Double in
        return 2*asin(sqrt(angle))
    }
    
    // Converts from degrees to radians
    let dToR = { (angle: Double) -> Double in
        return (angle / 360) * 2 * Double.pi
    }
    
    let lat1 = dToR(la1)
    let lon1 = dToR(lo1)
    let lat2 = dToR(la2)
    let lon2 = dToR(lo2)
    
    return radius * ahaversine(haversine(lat2 - lat1) + cos(lat1) * cos(lat2) * haversine(lon2 - lon1))
}
