//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    var businesses: [Business]!
    
    var searchBar: UISearchBar!
    
    var searchTerm : String = "Restaurants"
    
    @IBOutlet weak var bizListTableView: UITableView!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (businesses != nil) {
            println("count");
            println(businesses.count)
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = bizListTableView.dequeueReusableCellWithIdentifier("yelpCell", forIndexPath: indexPath) as! YelpCell
        var business = self.businesses[indexPath.row] as Business
        cell.bizTitleLabel.text = business.name
        cell.bizAddressLabel.text = business.address
        cell.bizDistanceLabel.text = business.distance
        cell.bizReviewLabel.text = "\(business.reviewCount!) Ratings"
        cell.bizTagsLabel.text = business.categories
        cell.bizImage.setImageWithURL(business.imageURL)
        cell.bizRatingImage.setImageWithURL(business.ratingImageURL)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bizListTableView.dataSource = self
        self.bizListTableView.delegate = self
        
        updateTable()
        
        // initialize UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // add search bar to navigation bar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        //self.bizListTableView.rowHeight = UITableViewAutomaticDimension
        //self.bizListTableView.estimatedRowHeight = 400
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSortBy() -> YelpSortMode {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var sortBy = userDefaults.valueForKey("sortBy") as! String
        
        switch(sortBy) {
            case "Best Match":
                return YelpSortMode.BestMatched
            case "Distance":
                return YelpSortMode.Distance
            case "Highest Rated":
                return YelpSortMode.HighestRated
        default:
            return YelpSortMode.Distance
            
        }
        
    }
    
    func getCategories() -> [String] {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var categories = userDefaults.valueForKey("Category") as? [String]
        if let categories = categories {
            return categories
        } else {
            return []
        }
    }
    
    func showDeals() -> Bool {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var deals = userDefaults.valueForKey("deals") as? Bool
        if let deals = deals {
            return deals
        } else {
            return false
        }

    }
    
    func updateTable() {

        Business.searchWithTerm(searchTerm, sort: getSortBy(), categories: getCategories(), deals: showDeals()) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            
            
            self.bizListTableView.reloadData()
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = "Cancel"
    }
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchTerm = searchBar.text
        searchBar.resignFirstResponder()
        updateTable()
        
    }

}
