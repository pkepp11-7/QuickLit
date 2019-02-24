//
//  ProfileViewController.swift
//  QuickLit
//
//  Created by Patrick Keppler on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StatsDelegate {
    
    var selectedRow: Int = 0
    var myStats: ProfileStats = ProfileStats()
    
    @IBOutlet weak var favoritesTable: UITableView!
    
    
    @IBOutlet weak var storiesCount: UIButton!
    
    @IBOutlet weak var likesCount: UIButton!
    
    @IBOutlet weak var followingCount: UIButton!
    
    @IBOutlet weak var followerCount: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var aboutTitleLable: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"favoritesSmallCell", for: indexPath) as! FavoritesSmallCell
        
        cell.authorStr = "testname"
        cell.titleStr = "testtitle"
        
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
        myStats.delegate = self
        myStats.getStats()
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.tableFooterView = UIView(frame: .zero)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "toStoriesList") {
            let storiesListVC = segue.destination as! ProfileStoryTableController
            storiesListVC.keyTitlePairs = myStats.userPosts
        }
        
    }


}
