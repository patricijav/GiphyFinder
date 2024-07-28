//
//  NetworkManager.swift
//  GiphyFinder
//
//  Created by Patrīcija Vainovska on 28/07/2024.
//

import Foundation

struct NetworkManager {
    let baseUrl: String = "https://api.giphy.com/v1/gifs/search"
    var giphyKey: String? = nil

    mutating func readGiphyKeyFromSecrets() {
        // Attempting to load the Giphy API key into the giphyKey variable
        //   Get the full path of the file
        //   Get the data object
        //   Read it as a property list
        //   Transform it into a dictionary with string keys
        //   Get the API key
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let plist = try? PropertyListSerialization.propertyList(from: xml, options: [], format: nil),
           let dict = plist as? [String: Any],
           let apiKey = dict["GiphyAPIKey"] as? String {
            giphyKey = apiKey
        }
    }

    func getRequestUrl(query: String, limit: Int = 25, offset: Int = 0) -> String? {
        if let key = giphyKey {
            return "\(baseUrl)?api_key=\(key)&q=\(query)&limit=\(limit)&offset=\(offset)"
        } else {
            return nil
        }
    }
}
