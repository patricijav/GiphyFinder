//
//  ViewController.swift
//  GiphyFinder
//
//  Created by Patrīcija Vainovska on 27/07/2024.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.text!)
        return true
    }
}
