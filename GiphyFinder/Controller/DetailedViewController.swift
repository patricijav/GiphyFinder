//
//  DetailedViewController.swift
//  GiphyFinder
//
//  Created by Patrīcija Vainovska on 28/07/2024.
//

import UIKit

class DetailedViewController: UIViewController {

    @IBOutlet weak var detailedGifImageView: UIImageView!

    var gifUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = gifUrl {
            detailedGifImageView.sd_setImage(with: URL(string: url), completed: nil)
        }
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
