//
//  ViewController.swift
//  GiphyFinder
//
//  Created by Patrīcija Vainovska on 27/07/2024.
//

import Network
import SDWebImage
import UIKit

class GridViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorStackView: UIStackView!
    @IBOutlet weak var searchTextField: UITextField!

    var networkManager = NetworkManager()
    var gifs: [String] = []
    // How many GIFs to load in a single call, max 50 for Beta keys
    let limit = 50
    var lastScheduledSearch: Timer?
    let monitor = NWPathMonitor()
    var hasInternet = false
    var isFetching = false

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        searchTextField.delegate = self

        networkManager.readGiphyKeyFromSecrets()

        monitor.pathUpdateHandler = {
            self.hasInternet = $0.status == .satisfied
            print("Device has internet connection: \(self.hasInternet)")
        }

        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)

        NotificationCenter.default.addObserver(self, selector: #selector(deviceWasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func deviceWasRotated() {
        // We need to refresh the collection view to have 2 columns
        self.collectionView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Close the keyboard when the user presses Return
        self.view.endEditing(true)

        return true
    }

    @IBAction func searchTextFieldChanged(_ sender: UITextField) {
        // If there was a waiting request, cancel it
        lastScheduledSearch?.invalidate()

        // Preparation stuff
        // Clear errors if there were any
        errorStackView.alpha = 0.0
        // Clear the current GIFs
        gifs = []
        self.collectionView.reloadData()

        // Don't send the request if the new value is an empty request
        if !sender.text!.isEmpty {
            // Schedule a search after 1 second
            lastScheduledSearch = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startSearching), userInfo: sender.text, repeats: false)
        }
    }

    @objc func startSearching(timer: Timer) {
        activityIndicator.startAnimating()
        // User has stopped typing, retrieve the necessary GIFs

        let searchText = timer.userInfo as! String

        // Check for errors
        if searchText.count > 50 {
            errorLabel.text = "Too many symbols"
            errorStackView.alpha = 1.0
            self.activityIndicator.stopAnimating()
            return
        } else if !hasInternet {
            errorLabel.text = "No internet"
            errorStackView.alpha = 1.0
            self.activityIndicator.stopAnimating()
            return
        }

        let requestUrl = networkManager.getRequestUrl(query: searchText, limit: limit)

        performRequest(urlString: requestUrl!)
    }

    func performRequest(urlString: String) {
        // So infinite scrolling doesn't get triggered too much (maybe we can move this)
        if isFetching {
            return
        }
        isFetching = true

        // Create a URL (and check if it doesn't fail)
        if let url = URL(string: urlString) {
            print("Request URL: \(url)")
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
                        // Currently retrieving original, to get some loading time inbetween,
                        //   but in the final version we can use fixed_width
                        let original = images!["original"] as? [String: Any]
                        let gifURL = original!["url"] as? String
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
            self.activityIndicator.stopAnimating()
        }

        isFetching = false
    }

    deinit {
        monitor.cancel()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

extension GridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        // To not have any duplicates when searching a new keyword
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // Create an UIImageView and add it to the cell's content view
        let imageView = UIImageView(frame: cell.contentView.frame)

        imageView.sd_setImage(with: URL(string: gifs[indexPath.item]), completed: nil)

        // Ensure the image takes the whole space, but isn't squished, but might be displaced
        imageView.contentMode = .scaleAspectFill

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true

        // Add the image view to the cell's content view
        cell.contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailed", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailed" {
            let destinationVC = segue.destination as! DetailedViewController
            destinationVC.gifUrl = gifs[(sender as! IndexPath).item]
        }
    }
}

extension GridViewController: UICollectionViewDelegateFlowLayout {
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

extension GridViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            // Currently need to be careful, as the string is not in the query type
            let textFieldText = self.searchTextField.text!

            let requestUrl = networkManager.getRequestUrl(query: textFieldText, limit: limit, offset: self.gifs.count)

            performRequest(urlString: requestUrl!)
        }
    }
}
