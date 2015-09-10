//
//  FilterViewController.swift
//  Yelp
//
//  Created by Golak Sarangi on 9/8/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var filterTable: UITableView!
    var filterDict :[NSMutableDictionary] = [
        [
            "name": "deals",
            "labels": [
                "Offering a Deal"
            ],
            "defaultValue": false
        ],
        [
            "title": "Category",
            "name": "category",
            "labels": [
                "Afghan",
                "African",
                "American"
            ],
            "defaultValue": "Afghan"
        ],
        [
            "title": "Sort By",
            "name": "sortBy",
            "labels": [
                "Best Match"
            ],
            "toggledLabel": [
                "Best Match",
                "Distance",
                "Highest Rated"
            ],
            "show": false,
            "defaultValue": "Best Match"
        ],
        [
            "title": "Distace",
            "name": "distance",
            "labels": [
                5
            ],
            "toggledLabel":[
                0.3, 1, 1.4, 5
            ],
            "show": false,
            "defaultValue": 5
        ]
    ]
// Labels should be a key value
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filterDict.count;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var labelsArr : NSArray
        var filterSection = filterDict[section]
        if (filterSection["show"] != nil && filterSection["show"] as! Bool && filterSection["toggledLabel"] != nil) {
            labelsArr = (filterSection["toggledLabel"] as! NSArray)
        } else {
            labelsArr = (filterSection["labels"] as! NSArray)
        }
        return labelsArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = filterTable.dequeueReusableCellWithIdentifier("filterCell", forIndexPath: indexPath) as! FilterCell
        
        var filterSection = filterDict[indexPath.section]
        var name = filterSection["name"] as! String
        var labelsArr : NSArray
        var toggled : Bool = false
        if (filterSection["show"] != nil && filterSection["show"] as! Bool && filterSection["toggledLabel"] != nil) {
            labelsArr = (filterSection["toggledLabel"] as! NSArray)
            toggled = true;
        } else {
            labelsArr = (filterSection["labels"] as! NSArray)
        }
        switch(name) {
            case "deals":
                showToggleControl(cell, labelStr: "\(labelsArr[indexPath.row])", enableToggling: false, id: indexPath.section)
            case "distance", "sortBy":
                var userDefaults = NSUserDefaults.standardUserDefaults()
                var currVal = userDefaults.valueForKey(name) as? String
                
                if (!toggled) {
                    if let currVal = currVal {
                    } else {
                        currVal = "\(labelsArr[indexPath.row])"
                    }
                } else {
                    currVal = "\(labelsArr[indexPath.row])"
                }
                showToggleControl(cell, labelStr: currVal!, enableToggling: !(filterSection["show"] as! Bool),  id: indexPath.section)
            case "category":
                showToggleControl(cell, labelStr: labelsArr[indexPath.row] as! String, enableToggling: false,  id: indexPath.section)
            
            default:
                println("not supported filter")
            
            
        }
        return cell
    }
    
    
    func showToggleControl (cell: FilterCell, labelStr: String, enableToggling: Bool, id: Int ) {
        var name = filterDict[id]["name"] as! String
        var currVal = getCurrentValue(name, labelStr: labelStr)
        if (name == "distance") {
            //TODO Instead of using labelStr directly better if there can be an id and a display value
            cell.controlLabel.text = labelStr + " miles"
        } else {
            cell.controlLabel.text = labelStr
        }
        cell.controlHolder.removeSubviews()
        if (enableToggling) {
            let toggleLabel = UILabel()
            toggleLabel.text = "v"
            toggleLabel.sizeToFit()
            cell.controlHolder.addSubview(toggleLabel)
        } else {
            var switchView = FilterSwitch()
            switchView.filterId = id
            switchView.filterLabel = labelStr

            switchView.setOn(currVal, animated:true)
            switchView.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            cell.controlHolder.addSubview(switchView)
        }
    }
    
    
    func stateChanged(switchView: FilterSwitch) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var filterName = filterDict[switchView.filterId!]["name"] as! String
        switch(filterName) {
        case "deals":
            userDefaults.setBool(switchView.on, forKey: filterName)
        case "distance", "sortBy":
            if (switchView.on) {
                userDefaults.setValue(switchView.filterLabel, forKey: filterName)
            }
            if (filterDict[switchView.filterId!]["show"] != nil) {
                filterDict[switchView.filterId!].setValue(false, forKey: "show")
            }
            filterTable.reloadData()
        case "category":
            var categoryArr = userDefaults.valueForKey(filterName) as? NSMutableArray
            if (categoryArr == nil) {
                categoryArr = NSMutableArray();
            }
            if (switchView.on) {
                categoryArr?.addObject(switchView.filterLabel!)
            } else {
                println("trying to remove")
                println(categoryArr)
                println(switchView.filterLabel!)
                categoryArr?.removeObject(switchView.filterLabel!)
                println("removed")
            }
            userDefaults.setValue(categoryArr, forKey: filterName)
        default:
            println("what is it")
        }
    }
    
    
    func getCurrentValue(name: String, labelStr: String) -> Bool {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var savedDefault = userDefaults.valueForKey(name)
        var retVal : Bool?
        if (savedDefault == nil) {
            return false
        }
        
        switch(name) {
            case "deals":
                retVal = savedDefault as? Bool
            case "distance", "sortBy":
                retVal = labelStr == savedDefault as? String
            case "category":
                retVal = (savedDefault as? NSArray)?.containsObject(labelStr)
            default:
                retVal = false
        }
        return retVal!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var filterSection = filterDict[indexPath.section]
        if (filterSection["show"] != nil) {
            filterDict[indexPath.section].setValue(!(filterSection["show"] as! Bool), forKey: "show")
        }
        filterTable.reloadData()
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var filterSection = filterDict[section]
        if let title = filterSection["title"] as? String {
            return title
        } else {
            return ""
        }
    }
    

    
    override func viewDidLoad() {
        self.filterTable.dataSource = self;
        self.filterTable.delegate = self;
    }

}


class FilterCell: UITableViewCell {
    
    @IBOutlet weak var controlLabel: UILabel!
    @IBOutlet weak var controlHolder: UIView!
}


class FilterSwitch: UISwitch {
    var filterId : Int?
    var filterLabel : String?

}


extension UIView {
    func removeSubviews (){
        for subview in self.subviews as! [UIView] {
            subview.removeFromSuperview()
        }
    }
}
