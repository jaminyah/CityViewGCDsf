//
//  ViewController.swift
//  CityViewGCDsf
//
//  Created by Jaminyah on 11/19/17.
//  Copyright © 2017 Jaminyah. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDelegate {
    
    let cellIdentifier = "CellIdentifier"
    
    // Create URLSession that uses a delegate
    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    var receivedData: NSData?
    let url = URL(string: "http://cdn.jaminya.com/json/cities.json")!
    
    
    // Local data to populate UITableView
    private let mountains = ["Denali", "Mount Logan", "Pico de Orizaba", "Mount Saint Elias", "Popocatépetl", "Mount Foraker",
                           "Mount Lucania", "Iztaccíhuatl", "King Peak", "Mount Bona", "Mount Steele", "Cofre de Perote", "Mount Sanford",
                           "Volcán Tajumulco", "Grand Teton", "Mount Slaggard", "Nevado de Toluca", "Nevado de Colima", "La Malinche", "Castle Peak"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.receivedData = data as NSData?
                
                // Display received data in console debugger
                if let data = data {
                    if let jsonData = String(data: data, encoding: String.Encoding.utf8)
                    {
                        print(jsonData)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK:-
    // MARK: Table View Data Source Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mountains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(
                style: UITableViewCellStyle.default,
                reuseIdentifier: cellIdentifier
            )
        }
        cell?.textLabel?.text = mountains[indexPath.row]
        return cell!
    }    
}

