//
//  ProfileViewController.swift
//  QuickLit
//
//  Created by Patrick Keppler on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StatsDelegate {
    
    var selectedRow: Int = 0
    var myStats: ProfileStats = ProfileStats()
    var myLibrary: ProfileStats = ProfileStats()
    
    @IBOutlet weak var favoritesTable: UITableView!
    
    
    @IBOutlet weak var storiesCount: UIButton!
    
    @IBOutlet weak var likesCount: UIButton!
    
    @IBOutlet weak var followingCount: UIButton!
    
    @IBOutlet weak var followerCount: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var aboutTitleLable: UILabel!
    
    @IBOutlet weak var cellStoryLabel: UILabel!
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
                performSegue(withIdentifier: "returnHome", sender: self)
        }
            catch let error as NSError {
                print(error.localizedDescription)
            }
    }
    
    
    @IBAction func storiesCounterPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toStoriesList", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var minValue = 3
        if(myLibrary.libraryPosts.count < minValue) {
            minValue = myLibrary.libraryPosts.count
        }
        return minValue
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"favoritesSmallCell", for: indexPath) as! FavoritesSmallCell
        cell.storyTitle.text = myLibrary.libraryPosts[indexPath.row]
        return cell
    }
    
    func update() {
        self.storiesCount.setTitle(String(myStats.storiesCount), for: .normal)
        self.usernameLabel.text = myStats.username
        self.aboutTitleLable.text = "About \(myStats.username)"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        likesCount.setTitle("0", for: .normal)
        followingCount.setTitle("0", for: .normal)
        followerCount.setTitle("0", for: .normal)
        myStats.delegate = self
        myStats.getStats()
        myLibrary.delegate = self
        myLibrary.getLibrary()
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.tableFooterView = UIView(frame: .zero)
    }
    
    
    
    func updateLibrary() {
        favoritesTable.reloadData()
    }

    @IBAction func morePressed(_ sender: Any) {
        performSegue(withIdentifier: "toLibraryTable", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "toStoriesList") {
            let storiesListVC = segue.destination as! ProfileStoryTableController
            //print(myStats.userPosts)
            storiesListVC.keyTitlePairs = myStats.userPosts
        }
        
        if(segue.identifier == "toLibraryTable") {
            let libraryTableVc = segue.destination as! LibraryTableViewController
            libraryTableVc.libraryKeys = myLibrary.libraryKeys
        }
        
        if(segue.identifier == "returnHome") {
            let rootVC = segue.destination
        }
        
    }


}
