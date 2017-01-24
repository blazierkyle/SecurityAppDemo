//
//  ViewController.swift
//  SecureWebServiceDemo
//
//  Created by Kyle Blazier on 1/22/17.
//  Copyright © 2017 Kyle Blazier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var returnValueTextView: UITextView!
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        
        urlTextField.autocorrectionType = .no
        urlTextField.spellCheckingType = .no
        urlTextField.autocapitalizationType = .none
        urlTextField.delegate = self
        
        returnValueTextView.isEditable = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func submitButtonPressed() {
        
        urlTextField.resignFirstResponder()
        
        // Form a URL from the entered URL
        guard let urlString = urlTextField.text else {
            presentAlert(alertTitle: "Error", alertMessage: "Please enter a URL of the webservice.")
            return
        }
        
        guard let url = URL(string: urlString) else {
            presentAlert(alertTitle: "Error", alertMessage: "Please enter a valid URL.")
            return
        }
        
        DispatchQueue.main.async(execute: {
            self.returnValueTextView.text = "Making the HTTP request now..."
        })
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                DispatchQueue.main.async(execute: { 
                    self.returnValueTextView.text = error.localizedDescription
                })
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async(execute: {
                    self.returnValueTextView.text = "No decodable response"
                })
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                DispatchQueue.main.async(execute: {
                    self.returnValueTextView.text = "Bad response code: \(httpResponse.statusCode)"
                })
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async(execute: {
                    self.returnValueTextView.text = "No data to decode"
                })
                return
            }
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    DispatchQueue.main.async(execute: {
                        self.returnValueTextView.text = "\(json)"
                    })
                } else {
                    // Couldn't convert to dictionary - try converting to a String
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        DispatchQueue.main.async(execute: {
                            self.returnValueTextView.text = "\(str)"
                        })
                    } else {
                        // Error
                        DispatchQueue.main.async(execute: {
                            self.returnValueTextView.text = "Encountered an error converting the data to a dictionary or string."
                        })
                    }
                }
                
            } catch let error {
                DispatchQueue.main.async(execute: {
                    self.returnValueTextView.text = error.localizedDescription
                })
            }
            
        }
        
        task.resume()
        
    }

}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitButtonPressed()
        return true
    }
}

extension UIViewController {
    
    // MARK: - Utility function to present actionable alerts and popups
    func presentAlert(alertTitle : String, alertMessage : String, cancelButtonTitle : String = "OK", cancelButtonAction : (()->())? = nil, okButtonTitle : String? = nil, okButtonAction : (()->())? = nil, thirdButtonTitle : String? = nil, thirdButtonAction : (()->())? = nil) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        if let okAction = okButtonTitle {
            alert.addAction(UIAlertAction(title: okAction, style: .default, handler: { (action) in
                okButtonAction?()
            }))
            
            if let thirdButton = thirdButtonTitle {
                alert.addAction(UIAlertAction(title: thirdButton, style: .default, handler: { (action) in
                    thirdButtonAction?()
                }))
            }
        }
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.cancel, handler: { (action) in
            cancelButtonAction?()
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

