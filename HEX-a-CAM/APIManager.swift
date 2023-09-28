//
//  APIManager.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/24/23.
//


import Foundation

struct ColorInfo: Decodable {
    let name: [String: String]
}

func fetchColorInfo(hex: String, completion: @escaping (ColorInfo?) -> Void) {
    let urlString = "https://www.thecolorapi.com/id?hex=\(hex)"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
        if let data = data,
           let colorInfo = try? JSONDecoder().decode(ColorInfo.self, from: data) {
            completion(colorInfo)
        } else {
            completion(nil)
        }
    }.resume()
}
