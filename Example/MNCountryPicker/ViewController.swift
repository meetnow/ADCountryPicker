//
//  ViewController.swift
//  MNCountryPicker
//
//  Created by Patrick Schneider on 18.06.17.
//  Copyright © 2017 MeetNow. All rights reserved.
//

import MNCountryPicker

class ViewController: UIViewController {
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var countryDialCodeLabel: UILabel!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "present_country_picker" {
            let nav = segue.destination as! UINavigationController
            let picker = nav.viewControllers[0] as! MNCountryPicker
            
            picker.showCallingCodes = true
            picker.delegate = self
            
            picker.didSelectCountryClosure = { _, code, _ in
                picker.dismiss(animated: true)
                print(code)
            }
        }
    }
}

extension ViewController: MNCountryPickerDelegate {
    func countryPicker(_ picker: MNCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        self.countryNameLabel.text = name
        self.countryCodeLabel.text = code
        self.countryDialCodeLabel.text = dialCode
    }
}
