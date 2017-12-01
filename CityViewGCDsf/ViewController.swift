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
    
    // Properties for caching
    let imageCache = NSCache<NSString, NSData>()
    
    // Create URLSession that uses a delegate
    private lazy var session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let url = URL(string: "http://cdn.jaminya.com/json/cities.json")!
    var jsonObjects: NSArray?
    
    @IBOutlet weak var cityTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cache 20 images
        self.imageCache.countLimit = 20
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                // Display received data in console debugger
                if let data = data {
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        if let major_cities = json["major_cities"] as? NSArray {
                            self.jsonObjects = major_cities
                            
                            // print city objects in console debugger
                            print(self.jsonObjects!)
                            
                            DispatchQueue.main.async {
                                // Refresh table view
                                self.cityTableView.reloadData()
                            }
                        }
                    
                        // Display to console debugger
                       /* if let jsonData = String(data: data, encoding: String.Encoding.utf8)
                        {
                            print(jsonData)
                        }*/
                        
                    } catch let error as NSError {
                        print("Failed to parse: \(error.localizedDescription)")
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
       /* if self.jsonObjects != nil {
            return self.jsonObjects!.count
        } else {
            return 15
        }*/
        if let cities = self.jsonObjects {
            return cities.count
        } else {
            return 15   // arbitrary value
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(
                style: UITableViewCellStyle.default,
                reuseIdentifier: cellIdentifier
            )
        }
        
        if let cityObject = self.jsonObjects?[indexPath.row] as? NSDictionary
        {
            cell?.textLabel?.text = cityObject["city"] as? String
            
            // Check if image is cached
            let flagKey = cityObject["slug"] as? NSString
            
            if let cachedImageData = self.imageCache.object(forKey: flagKey!) {
                print("Fetching from cache: \(flagKey!)")
                let imgData = cachedImageData as Data
                
                // Set state flag image
                cell?.imageView?.image = UIImage(data: imgData)
            } else {
            
                let urlString = cityObject["flagUrl"] as? String
                let flagUrl = URL(string: urlString!)!
                let session = URLSession(configuration: .default)
            
                let downloadTask = session.dataTask(with: flagUrl) { (data, response, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else
                    {
                        if let imageData = data {
                        
                            // Cached image
                            print("Fetching from network: \(flagKey!)")
                            let fetchedImageData = imageData as NSData
                            self.imageCache.setObject(fetchedImageData, forKey: flagKey!)
                            
                            // Display state flag image on main thread
                            DispatchQueue.main.async {
                                cell?.imageView?.image = UIImage(data: imageData)
                            }
                    }
                }
            }
                downloadTask.resume()
            }
            
        } else {
            cell?.textLabel?.text = "city_name"
            cell?.imageView?.image = UIImage(named: "Placeholder.png")
        }
        return cell!
    }    
}
