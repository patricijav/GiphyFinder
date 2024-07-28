//
//  ViewController.swift
//  GiphyFinder
//
//  Created by Patrīcija Vainovska on 27/07/2024.
//

import UIKit
import SDWebImage

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!

    var giphyKey: String? = nil
    var gifs: [String] = []
    // How many GIFs to load in a single call, max 50 for Beta keys
    let limit = 50

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

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
        // Clear GIFs on Return pressed
        gifs = []

        // Currently need to be careful, as the string is not in the query type
        let textFieldText = textField.text!

        let requestUrl = "https://api.giphy.com/v1/gifs/search?q=\(textFieldText)&api_key=\(giphyKey!)&limit=\(limit)"

        performRequest(urlString: requestUrl)

        return true
    }

    func performRequest(urlString: String) {
        print("Request URL: \(urlString)")
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
                if let json = try JSONSerialization.jsonObject(with: safeData) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]] {
                    // Taking the first element (GIF)
                    // Looking at the images, which is a dictionary of different size versions
                    // Taking the original image version
                    // Taking the URL to the specific version
                    for gif in dataArray {
                        // This part could be cleaned up
                        let images = gif["images"] as? [String: Any]
                        let fixedHeightSmall = images!["fixed_height_small"] as? [String: Any]
                        let gifURL = fixedHeightSmall!["url"] as? String
                        print("GIF [\(gifs.count)] URL: \(gifURL!)")
                        gifs.append(gifURL!)
                    }
                } else {
                    print("Error parsing JSON!")
                }
            } catch {
                // Not the correct structure, for example
                print("Error parsing JSON: \(error)")
            }
        }

        // Reload collection view
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        // Create an UIImageView and add it to the cell's content view
        let imageView = UIImageView(frame: cell.contentView.frame)
        imageView.sd_setImage(with: URL(string: gifs[indexPath.item]), completed: nil)

        // Ensure the image takes the whole space, but isn't squished, but might be displaced
        imageView.contentMode = .scaleAspectFill

        // Add the image view to the cell's content view
        cell.contentView.addSubview(imageView)

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let collectionViewWidth = collectionView.bounds.width
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let spaceBetweenCells = flowLayout.minimumInteritemSpacing * (columns - 1)
        let adjustedWidth = collectionViewWidth - spaceBetweenCells
        let width: CGFloat = adjustedWidth / columns
        // To make it a square
        // Additionally: we could also set pixels if we wanted to fit more images, for example, in landscape
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            // Currently need to be careful, as the string is not in the query type
            let textFieldText = self.searchTextField.text!

            let requestUrl = "https://api.giphy.com/v1/gifs/search?q=\(textFieldText)&api_key=\(giphyKey!)&limit=\(limit)&offset=\(self.gifs.count)"

            performRequest(urlString: requestUrl)
        }
    }
}
