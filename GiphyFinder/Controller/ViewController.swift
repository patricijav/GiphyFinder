//
//  ViewController.swift
//  GiphyFinder
//
//  Created by Patrīcija Vainovska on 27/07/2024.
//

import UIKit
import SDWebImage

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!

    var giphyKey: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self

        // Loading the Giphy API key into the giphyKey variable
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldText = textField.text!
        print(textFieldText)

        let requestUrl = "https://api.giphy.com/v1/gifs/search?q=gossip+girl&api_key=\(giphyKey!)&limit=1"

        performRequest(urlString: requestUrl)

        return true
    }

    func performRequest(urlString: String) {
        // Create a URL (and check if it doesn't fail)
        if let url = URL(string: urlString) {
            // Create a URLSession with the defaul configuration
            let session = URLSession(configuration: .default)
            // Give the session a task
            let task = session.dataTask(with: url, completionHandler: handleResponse(data:response:error:))
            // Start the task
            task.resume()
        }
    }

    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
            return
        }

        if let safeData = data {
            do {
                // Casting JSON object as [String: Any], because the top level structure is a dictionary
                // dataArray is a array of dictionaries
                // Taking the first element (GIF)
                // Looking at the images, which is a dictionary of different size versions
                // Taking the original image version
                // Taking the URL to the specific version
                if let json = try JSONSerialization.jsonObject(with: safeData) as? [String: Any],
                    let dataArray = json["data"] as? [[String: Any]],
                    let firstGif = dataArray.first,
                    let images = firstGif["images"] as? [String: Any],
                    let original = images["original"] as? [String: Any],
                    let gifURL = original["url"] as? String {
                    print("GIF URL: \(gifURL)")
                    let gifURL2 = URL(string: gifURL)
                    // oneGifImageView.sd_setImage(with: gifURL2, placeholderImage: UIImage(named: "logo.png"))
                } else {
                    print("No GIF URL found")
                }
            } catch {
                // Not the correct structure, for example
                print("Error parsing JSON: \(error)")
            }
        }
    }
}
