//
//  MNCountry.swift
//  MNCountryPicker
//
//  Created by Amila on 21/04/2017.
//  Original work Copyright © 2017 Amila Diman. All rights reserved.
//  Modified work Copyright © 2017 MeetNow. All rights reserved.
//

import UIKit

// Note: using a subclass of NSObject here to allow use with UILocalizedIndexedCollation
public class MNCountry: NSObject {
    let name: String
    let code: String
    var section: Int?
    let dialCode: String
    
    init(name: String, code: String, dialCode: String = "?") {
        self.name = name
        self.code = code
        self.dialCode = dialCode
    }
}
