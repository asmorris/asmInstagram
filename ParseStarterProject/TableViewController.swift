//
//  TableViewController.swift
//  asmInstagram
//
//  Created by Andrew Morrison on 2016-03-17.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
    
    var usernames = [""]
    var userIDs = [""]
    var isFollowing = ["":false]
    var refresher:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        refresh()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Pull to refresh
    
    func refresh() {
        
        var query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                self.usernames.removeAll(keepCapacity: true)
                self.userIDs.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                
                for object in users {
                    if let user = object as? PFUser {
                        if user.objectId != PFUser.currentUser()?.objectId {
                            self.usernames.append(user.username!)
                            self.userIDs.append(user.objectId!)
                            
                            
                            var query = PFQuery(className: "followers")
                            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                if let objects = objects {
                                    
                                    if objects.count > 0 {
                                        
                                        self.isFollowing[user.objectId!] = true
                                        
                                    } else {
                                        self.isFollowing[user.objectId!] = false
                                    }
                                }
                                
                                if self.isFollowing.count == self.usernames.count {
                                    
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()

                                }
                            })
                        }
                    }
                }
                
            }
            
            
        })
        
        
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...

        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = userIDs[indexPath.row]
        
        if isFollowing[followedObjectId] == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }



    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!

        let followedObjectId = userIDs[indexPath.row]
        
        if isFollowing[followedObjectId] == false {
            isFollowing[followedObjectId] = true
            
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            var following = PFObject(className: "followers")
            following["following"] = userIDs[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            
            following.saveInBackground()
        } else {
            
            isFollowing[followedObjectId] = false
            cell.accessoryType = UITableViewCellAccessoryType.None

            
            var query = PFQuery(className: "followers")
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userIDs[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects {
                
                    for object in objects {
                        object.deleteInBackground()
                    }
                   
                }
                
            })

        }

    }
    
    
    
    

}
