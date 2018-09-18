//
//  SearchViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit
class SearchViewController : UITableViewController {
    
    // 1: Here you declared two arrays of dictionaries, the users array will store the data source
    // for the table view that will display the initial data, whereas the foundUsers array will handle
    // all the filtered informations displayed by another table view while you search.
    var users : [[String:AnyObject]]!
    var foundUsers : [[String:AnyObject]]!
    
    // 2: This will store the selected user informations in a dictionary to pass to the details view controller.
    var userDetails : [[String:AnyObject]]!
    
    // 3: Here you set two references for the search controller and its relevant results controller.
    //Remember, a results controller will manage the filtered data while you type in the search bar.
    var resultsController : UITableViewController!
    var searchController : UISearchController!
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = []
		foundUsers = []
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.automaticallyAdjustsScrollViewInsets = false
		
		/* 2: This will create a results controller that will work along with the UISearchController 
		to manage its filtered data. You defined the results controller as a UITableViewController 
		instance since it will come with a table view object by default. You then registered a cell 
		with an identifier for the table view and set the current view controller as the data source 
		and delegate of the table view. */
		configureResultsController()
		
		/* 3: Here you initialised the search controller with the results controller previously set.
		You also set the current controller as the searchResultsUpdater delegate, so this class will
		implement the relevant protocol method to react to the search bar changes and dynamically filter
		data accordingly. Setting the search controller’s search bar as the table view header will place
		it always at the top of the list. */
		configureSearchController()
		
		/* 4: This is very important, the current view controller will present a search controller over 
		its main view. Setting the definesPresentationContext property to true will indicate that the 
		view controller’s view will be covered each time the search controller is shown over it. This 
		will allow to avoid unknown behaviour. */
		self.definesPresentationCentext = true
		
		/* 5: This code will asynchronously request some set of data from the server and populate to 
		the table view. This is done using a download task attached to a session object. */
		requestDataFromServer()
    }
	
	func configureResultsController(){
		resultsController = UITableViewController(style: .Plain)
			resultsController.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
			resultsController.tableView.dataSource = self
			resultsController.tableView.delegate = self
	}
    
	func configureSearchController(){
		searchController = UISearchController(searchResultsController: resultsController)
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.searchBar.searchBarStyle = .Minimal
		searchController.searchResultsUpdater = self
	}
	
	func requestDataFromServer(){
		let session = NSURLSession.sharedSession()
		let url:NSURL! = NSURL(string: "https://jsonplaceholder.typicode.com/users")
		let task = session.downloadTaskWithURL(url) { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
		   
			guard location == nil else {
				// Error
				print("An error occurred \(error)")
			}
			
			let data:NSData! = NSData(contentsOfURL: location!)
			do{
				self.users = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as! [[String : AnyObject]]
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
				   self.tableView.reloadData()
				})
			}catch{
				// Catch any exception
				print("Something went wrong")
			}

		}
		// Start the download task
		task.resume()
	}
}

//MARK: UITableViewDataSource
extention SearchViewController : UITableViewDataSource{

	/* Nothing fancy from the code below, except that it always check which table view is calling the data source. 
	The check is important since the current view controller is dealing with two table views. */

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == self.tableView{
			return users.count
		}
		
		return foundUsers.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
		var cellIdentifier: String!
		var dic: [String:AnyObject]!
		
		if tableView == self.tableView {
			cellIdentifier = "UserCell"
			dic = self.users[indexPath.row]
		} else {
			cellIdentifier = "UserFoundCell"
			dic = self.foundUsers[indexPath.row]
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
		cell.textLable?.text = dic["name"] as? Sting
		return cell
	}
	
}

extention SearchViewController : UISearchResultsUpdating {
	
	/* The below method will be called when the search bar becomes first responder (when the keyboard shows up) 
	and each time a change is triggered inside the search bar. This seems to be the right place to dynamically 
	filter the data based on the search text and reload the results controller’s table view with the filtered 
	data. That’s typically what you did! */
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		foundUsers.removeAll()
		for user in users {
			let userName = user["name"] as? String
			if userName.localizedCaseInsensitiveContainsString(searchController.searchBar.text!){
				foundUsers.append(user)
				self.resultsController.tableView.reloadData()
			}
		}
	}
} 

extention SearchViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if tableView == resultsController.tableView{
			userDetails = foundUsers[indexPath.row]
			self.performSegueWithIdentifier("PushDetailsVC", sender: self)
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let detailsVC = segue.destinationViewController as! DetailsViewController
		detailsVC.userDetails = userDetails
	}
	
}
