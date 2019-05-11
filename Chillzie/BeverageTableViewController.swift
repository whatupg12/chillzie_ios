//
//  BeverageTableViewController.swift
//  Chillzie
//
//  Created by Anthony Dotterer on 3/31/19.
//  Copyright © 2019 Chillzie. All rights reserved.
//

import UIKit


class BeverageTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var completionHandler: ((Beverage) -> Void)?

    var beverages = [Beverage]()
    var filteredBeverages = [Beverage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beverages = [
            Beverage(name: "Vintage Port", temp: 65),
            Beverage(name: "Cab Sauvignon", temp: 65),
            Beverage(name: "Bordeaux", temp: 64),
            Beverage(name: "Syrah/Shiraz", temp: 64),
            Beverage(name: "Barolo", temp: 64),
            Beverage(name: "Red Burgundy", temp: 63),
            Beverage(name: "Barlo", temp: 63),
            Beverage(name: "Malbec", temp: 63),
            Beverage(name: "Grenache", temp: 63),
            Beverage(name: "Roija", temp: 61),
            Beverage(name: "Pinot", temp: 61),
            Beverage(name: "Cdp", temp: 61),
            Beverage(name: "Toro", temp: 61),
            Beverage(name: "Barbera", temp: 61),
            Beverage(name: "Chianti", temp: 59),
            Beverage(name: "Zinfandel", temp: 59),
            Beverage(name: "Pinot Noir", temp: 59),
            Beverage(name: "Chianti", temp: 59),
            Beverage(name: "Merlot", temp: 58),
            Beverage(name: "Dolcetto", temp: 58),
            Beverage(name: "Cotes du Rhone", temp: 58),
            Beverage(name: "Sherry", temp: 57),
            Beverage(name: "Port", temp: 57),
            Beverage(name: "Madeira", temp: 57),
            Beverage(name: "Chinon", temp: 57),
            Beverage(name: "Beaujolais", temp: 54),
            Beverage(name: "Rose", temp: 54),
            Beverage(name: "Valpolicella", temp: 54),
            Beverage(name: "Viognier", temp: 52),
            Beverage(name: "Sauternes", temp: 52),
            Beverage(name: "Beaune", temp: 52),
            Beverage(name: "Valpolicella", temp: 52),
            Beverage(name: "Chardonnay", temp: 50),
            Beverage(name: "Chablis", temp: 50),
            Beverage(name: "W. Zinfandel", temp: 50),
            Beverage(name: "Vintage Champage", temp: 47),
            Beverage(name: "W. Burgundy", temp: 47),
            Beverage(name: "Riesling", temp: 47),
            Beverage(name: "Muscadet", temp: 46),
            Beverage(name: "Moscato", temp: 46),
            Beverage(name: "Pinot Grigio", temp: 46),
            Beverage(name: "Champage", temp: 45),
            Beverage(name: "Sauvignon Blanc", temp: 45),
            Beverage(name: "Ice Wines", temp: 43),
            Beverage(name: "Cheap Rose", temp: 43),
            Beverage(name: "Prosecco", temp: 43),
            Beverage(name: "Cava", temp: 43),
            Beverage(name: "Asti", temp: 43),
        ]
        
        searchBar.delegate = self
        
    }
    
    // search bar delgate
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filterContentForSearchText(searchBar.text!, scope: "All")
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beverage: Beverage
        if isFiltering() {
            beverage = filteredBeverages[indexPath.row]
        } else {
            beverage = beverages[indexPath.row]
        }
        
        completionHandler?(beverage)
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredBeverages.count
        } else {
            return beverages.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeverageCell", for: indexPath)
        
        let beverage: Beverage
        if isFiltering() {
            beverage = filteredBeverages[indexPath.row]
        } else {
            beverage = beverages[indexPath.row]
        }
        
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = beverage.name
            //cell.textLabel!.text = beverage.name
            //cell.detailTextLabel!.text = String(beverage.temp)
        }
        
        return cell
    }
    
    
    // search bar stuff
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredBeverages = beverages.filter({( beverage : Beverage) -> Bool in
            return beverage.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }

}

struct Beverage {
    let name : String
    let temp : Double
}


