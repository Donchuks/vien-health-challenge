//
//  CountryListViewController.swift
//  Countries
//
//  Created by Syft on 03/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import UIKit
import CoreData


class CountryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var countryTableView: UITableView!
    var countries: [Country]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        countryTableView.rowHeight = UITableView.automaticDimension
        countryTableView.estimatedRowHeight = 100
        countryTableView.dataSource = self
        countryTableView.delegate = self
        countryTableView.accessibilityIdentifier = "CountryTable"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HUD.show(in: view.window!)
        Server.shared.countryList() { (error) in
            
            HUD.dismiss(from: self.view.window!)
            guard error == nil else {
                assertionFailure("There was an error: \(error!)")
                return
            }
            self.fetchCountries() //fetch countries
            self.countries?.sort(by: {$0.name ?? "" < $1.name ?? ""}) //sort coutries by name
            self.countryTableView.reloadData()
        }
    }
    
    func fetchCountries() {
        let mainContext = DataStore.shared.viewContext
        let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        do {
            countries = try mainContext.fetch(fetchRequest)
        }
        catch {
            debugPrint(error)
        }
        
    }
    
    // MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryInfoCell") as! CountryTableViewCell
        
        if let country = countries?[indexPath.row] {
            cell.country.text = country.name
            cell.capital.text = country.capital
            cell.population.text = self.formatPopulation(population: country.population)
            
            cell.accessibilityIdentifier = "\(country.name!)-Cell"
            cell.country.accessibilityIdentifier = "Country"
            cell.capital.accessibilityIdentifier = "\(country.name!)-Capital"
            
            //create accessibility for only if capital exists
            if !country.capital!.isEmpty {
                cell.capitalLabel.accessibilityIdentifier = "\(country.name!)-Capital-Label"
            }
            
            cell.population.accessibilityIdentifier = "\(country.name!)-Population"
            cell.populationLabel.accessibilityIdentifier = "\(country.name!)-Population-Label"

        }
        return cell
    }
    
    func formatPopulation(population: Int32) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: population)) else { return String(population) }
        return formattedNumber
    }
}
