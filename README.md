# MNCountryPicker

MNCountryPicker is a country picker controller for iOS8+ with an option to search.
The list of countries is based on the ISO 3166 country code standard
(http://en.wikipedia.org/wiki/ISO_3166-1).

The picker provides:
- Country Names
- Country codes - ISO 3166
- International Dialing Codes

## Screenshots

![alt tag](https://github.com/meetnow/MNCountryPicker/blob/master/screen1.png)
![alt tag](https://github.com/meetnow/MNCountryPicker/blob/master/screen2.png)
![alt tag](https://github.com/meetnow/MNCountryPicker/blob/master/screen3.png)

* Note: current location is determined from the current region of the iPhone

## Installation

MNCountryPicker is available through [CocoaPods](http://cocoapods.org), to
install it simply add the following line to your Podfile:
   
    use_frameworks!
    pod 'MNCountryPicker'

Push MNCountryPicker from UIViewController

```swift

let picker = MNCountryPicker(style: .grouped)
navigationController?.pushViewController(picker, animated: true)

```
Present MNCountryPicker from UIViewController

```swift

let picker = MNCountryPicker()
  let pickerNavigationController = UINavigationController(rootViewController: picker)
  self.present(pickerNavigationController, animated: true, completion: nil)

```
## MNCountryPicker properties

```swift

/// delegate
picker.delegate = self

/// Optionally, set this to display the country calling codes after the names
picker.showCallingCodes = true

/// The nav bar title to show on picker view
picker.pickerTitle = "Select a Country"
    
/// The default current location, if region cannot be determined. Defaults to US
picker.defaultCountryCode = "US"
    
/// The text color of the alphabet scrollbar. Defaults to black
picker.alphabetScrollBarTintColor = UIColor.black
    
/// The background color of the alphabet scrollar. Default to clear color
picker.alphabetScrollBarBackgroundColor = UIColor.clear
    
/// The tint color of the close icon in presented pickers. Defaults to black
picker.closeButtonTintColor = UIColor.black
    
/// The font of the country name list
picker.font = UIFont(name: "Helvetica Neue", size: 15)

/// Flag to indicate if the navigation bar should be hidden when search becomes active. Defaults to true
picker.hidesNavigationBarWhenPresentingSearch = true
    
/// The background color of the searchbar. Defaults to lightGray
picker.searchBarBackgroundColor = UIColor.lightGray

```
## MNCountryPickerDelegate protocol

```swift

func countryPicker(picker: MNCountryPicker, didSelectCountryWithName name: String, code: String) {
        print(code)
}

func countryPicker(picker: MNCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        print(dialCode)
}
```

## Closure

```swift

// or closure
picker.didSelectCountryClosure = { name, code in
        print(code)
}

picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
        print(dialCode)
}

```

## Author

Patrick Schneider, patrick.schneider@meetnow.eu

Original work by:

Amila Dimantha, amilasumanasiri@hotmail.com

Core based on work of @mustafaibrahim989

## Notes

Fork of [ADCountryPicker](https://github.com/AmilaDiman/ADCountryPicker)

Designed for iOS 8+.

## License

MNCountryPicker is available under the MIT license. See the LICENSE file for more info.
