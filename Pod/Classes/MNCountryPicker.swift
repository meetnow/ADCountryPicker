//
//  MNCountryPicker.swift
//  MNCountryPicker
//
//  Created by Ibrahim, Mustafa on 1/24/16.
//  Original work Copyright © 2016 Mustafa Ibrahim. All rights reserved.
//  Modified work Copyright © 2017 MeetNow. All rights reserved.
//

import UIKit

struct Section {
    var countries: [MNCountry] = []
    mutating func addCountry(_ country: MNCountry) {
        self.countries.append(country)
    }
}

public protocol MNCountryPickerDelegate: class {
    func countryPicker(_ picker: MNCountryPicker,
                       didSelectCountryWithName name: String,
                       code: String,
                       dialCode: String)
}

open class MNCountryPicker: UITableViewController {
    
    private var customCountriesCode: [String]?
    
    fileprivate lazy var callingCodes = { () -> [[String: String]] in
        let bundle = Bundle(for: MNCountryPicker.classForCoder())
        guard let resourceBundleURL = bundle.url(forResource: "MNCountryPicker", withExtension: "bundle") else { return [] }
        guard let resourceBundle = Bundle(url: resourceBundleURL) else { return [] }
        guard let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist") else { return [] }
        return NSArray(contentsOfFile: path) as! [[String: String]]
    }()
    fileprivate var searchController: UISearchController!
    fileprivate var filteredList = [MNCountry]()
    fileprivate var unsortedCountries: [MNCountry] {
        let locale = Locale.current
        var unsortedCountries = [MNCountry]()
        let countriesCodes = self.customCountriesCode == nil ? Locale.isoRegionCodes : self.customCountriesCode!
        
        for countryCode in countriesCodes {
            let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
            let countryData = self.callingCodes.filter { $0["code"] == countryCode }
            let country: MNCountry
            
            if countryData.count > 0, let dialCode = countryData[0]["dial_code"] {
                country = MNCountry(name: displayName!, code: countryCode, dialCode: dialCode)
            }
            else {
                country = MNCountry(name: displayName!, code: countryCode)
            }
            unsortedCountries.append(country)
        }
        
        return unsortedCountries
    }
    
    fileprivate var _sections: [Section]?
    fileprivate var sections: [Section] {
        if self._sections != nil {
            return self._sections!
        }
        
        let countries: [MNCountry] = self.unsortedCountries.map { country in
            let country = MNCountry(name: country.name, code: country.code, dialCode: country.dialCode)
            country.section = self.collation.section(for: country, collationStringSelector: #selector(getter: MNCountry.name))
            return country
        }
        
        // create empty sections
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        // put each country in a section
        for country in countries {
            sections[country.section!].addCountry(country)
        }
        
        // sort each section
        for section in sections {
            var s = section
            s.countries = self.collation.sortedArray(from: section.countries, collationStringSelector: #selector(getter: MNCountry.name)) as! [MNCountry]
        }
        
        // Adds current location
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? self.defaultCountryCode
        sections.insert(Section(), at: 0)
        let locale = Locale.current
        let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
        let countryData = self.callingCodes.filter { $0["code"] == countryCode }
        let country: MNCountry
        
        if countryData.count > 0, let dialCode = countryData[0]["dial_code"] {
            country = MNCountry(name: displayName!, code: countryCode, dialCode: dialCode)
        } else {
            country = MNCountry(name: displayName!, code: countryCode)
        }
        country.section = 0
        sections[0].addCountry(country)
        
        self._sections = sections
        
        return self._sections!
    }
    
    fileprivate let collation = UILocalizedIndexedCollation.current()
    
    open weak var delegate: MNCountryPickerDelegate?
    
    /// Closure which returns country name, ISO code, calling codes
    open var didSelectCountryClosure: ((String, String, String) -> ())?
    
    /// Flag to indicate if calling codes should be shown next to the country name. Defaults to false.
    open var showCallingCodes = false
    
    /// The default current location, if region cannot be determined. Defaults to US
    open var defaultCountryCode = "US"
    
    /// The text color of the alphabet scrollbar. Defaults to black
    open var alphabetScrollBarTintColor = UIColor.black
    
    /// The background color of the alphabet scrollar. Default to clear color
    open var alphabetScrollBarBackgroundColor = UIColor.clear
    
    /// The tint color of the close icon in presented pickers. Defaults to black
    open var closeButtonTintColor = UIColor.black
    
    /// The font of the country name list
    open var countryCellFont = UIFont.systemFont(ofSize: 16.0)
    
    /// Cell reuse identifier if styling is done via Storyboard; overrides countryCellFont setting
    @IBInspectable
    open var countryCellReuseIdentifier: String? = nil
    
    /// Flag to indicate if the navigation bar should be hidden when search becomes active. Defaults to true
    open var hidesNavigationBarWhenPresentingSearch = true
    
    /// The background color of the searchbar. Defaults to lightGray
    open var searchBarBackgroundColor = UIColor.lightGray
    
    /// The label of the "Current Location" header
    open var currentLocationLabel = "Current Location"
    
    convenience public init(completionHandler: @escaping ((String, String, String) -> ())) {
        self.init()
        self.didSelectCountryClosure = completionHandler
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.createSearchBar()
        self.tableView.reloadData()
        
        self.definesPresentationContext = true
        
        if self.presentingViewController != nil {
            var closeIcon: UIImage? = nil
            let bundle = Bundle(for: MNCountryPicker.classForCoder())
            if let resourceBundleURL = bundle.url(forResource: "MNCountryPicker", withExtension: "bundle"),
                    let resourceBundle = Bundle(url: resourceBundleURL) {
                closeIcon = UIImage(named: "close_icon", in: resourceBundle, compatibleWith: nil)
            }
            
            let closeButton: UIBarButtonItem!
            if closeIcon != nil {
                closeButton = UIBarButtonItem(image: closeIcon,
                                              style: .plain,
                                              target: self,
                                              action: #selector(self.dismissView))
            }
            else {
                closeButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                              target: self,
                                              action: #selector(self.dismissView))
            }
            
            closeButton.tintColor = self.closeButtonTintColor
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = closeButton
        }
        
        self.tableView.sectionIndexColor = self.alphabetScrollBarTintColor
        self.tableView.sectionIndexBackgroundColor = self.alphabetScrollBarBackgroundColor
        self.tableView.separatorColor = UIColor(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    }
    
    // MARK: Methods
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func createSearchBar() {
        if self.tableView.tableHeaderView == nil {
            self.searchController = UISearchController(searchResultsController: nil)
            self.searchController.searchResultsUpdater = self
            self.searchController.dimsBackgroundDuringPresentation = false
            self.searchController.hidesNavigationBarDuringPresentation = self.hidesNavigationBarWhenPresentingSearch
            self.searchController.searchBar.searchBarStyle = .prominent
            self.searchController.searchBar.barTintColor = self.searchBarBackgroundColor
            self.searchController.searchBar.showsCancelButton = false
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
    }
    
    @discardableResult
    fileprivate func filter(_ searchText: String) -> [MNCountry] {
        self.filteredList.removeAll()
        
        self.sections.forEach { (section) -> () in
            section.countries.forEach({ (country) -> () in
                if country.name.characters.count >= searchText.characters.count {
                    let result = country.name.compare(searchText, options: [.caseInsensitive, .diacriticInsensitive],
                                                      range: searchText.characters.startIndex ..< searchText.characters.endIndex)
                    if result == .orderedSame {
                        self.filteredList.append(country)
                    }
                }
            })
        }
        
        return self.filteredList
    }
}

// MARK: - Table view data source

extension MNCountryPicker {
    override open func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchController.searchBar.text!.characters.count > 0 {
            return 1
        }
        return self.sections.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.searchBar.text!.characters.count > 0 {
            return self.filteredList.count
        }
        return self.sections[section].countries.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if let reuseIdentifier = self.countryCellReuseIdentifier {
            cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
        }
        else {
            let maybeCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
            if maybeCell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
                cell.textLabel?.font = self.countryCellFont
            }
            else {
                cell = maybeCell
            }
        }
        
        let country: MNCountry!
        if self.searchController.searchBar.text!.characters.count > 0 {
            country = self.filteredList[indexPath.row]
        }
        else {
            country = self.sections[indexPath.section].countries[indexPath.row]
        }
        
        if self.showCallingCodes {
            cell.textLabel?.text = "\(country.name) (\(country.dialCode))"
        }
        else {
            cell.textLabel?.text = country.name
        }
        
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.sections[section].countries.isEmpty {
            if self.searchController.searchBar.text!.characters.count > 0 {
                if let name = self.filteredList.first?.name {
                    let index = name.index(name.startIndex, offsetBy: 0)
                    return String(describing: name[index])
                }
                
                return ""
            }
            
            if section == 0 {
                return self.currentLocationLabel
            }
            
            return self.collation.sectionTitles[section-1] as String
        }
        
        return ""
    }
    
    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        else {
            return 26
        }
    }
    
    override open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    override open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.collation.section(forSectionIndexTitle: index+1)
    }
}

// MARK: - Table view delegate

extension MNCountryPicker {
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let country: MNCountry!
        if self.searchController.searchBar.text!.characters.count > 0 {
            country = self.filteredList[indexPath.row]
        }
        else {
            country = self.sections[indexPath.section].countries[indexPath.row]
        }
        
        self.delegate?.countryPicker(self, didSelectCountryWithName: country.name, code: country.code, dialCode: country.dialCode)
        self.didSelectCountryClosure?(country.name, country.code, country.dialCode)
    }
}

// MARK: - UISearchDisplayDelegate

extension MNCountryPicker: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        self.filter(searchController.searchBar.text!)
        
        if !self.hidesNavigationBarWhenPresentingSearch {
            searchController.searchBar.showsCancelButton = false
        }
        
        self.tableView.reloadData()
    }
}
