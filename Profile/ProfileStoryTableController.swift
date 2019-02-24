//
//  ProfileStoryTableController.swift
//  QuickLit
//
//  Created by Patrick Keppler on 2/24/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class ProfileStoryTableController: UITableViewController {
    
    var keyTitlePairs: [String : String] = [:]
    var profileStories: [story] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return keyTitlePairs.count
    }
    
    func getProfileStories() {
        let firebaseRef: DatabaseReference? = Database.database().reference()
        let storiesPath = firebaseRef?.child("Stories")
        storiesPath?.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                
                let postID = snap.key
                var post_author = ""
                var date_published = ""
                var genre = ""
                var story_text = ""
                var title = ""
                var likes = -1
                var comments = [comment]()
                
                let post_author_snap = snap.childSnapshot(forPath: "author")
                if let post_author_value = post_author_snap.value as? String {
                    post_author = post_author_value
                }
                
                let date_published_snap = snap.childSnapshot(forPath: "date_published")
                if let date_published_value = date_published_snap.value as? String {
                    date_published = date_published_value
                }
                
                let genre_snap = snap.childSnapshot(forPath: "genre")
                if let genre_value = genre_snap.value as? String  {
                    genre = genre_value
                }
                
                let story_snap = snap.childSnapshot(forPath: "story")
                if let story_value = story_snap.value as? String {
                    story_text = story_value
                }
                
                let title_snap = snap.childSnapshot(forPath: "title")
                if let title_value = title_snap.value as? String {
                    title = title_value
                }
                
                if(snap.childSnapshot(forPath: "likes").exists()){
                    let likes_snap = snap.childSnapshot(forPath: "likes")
                    if let likes_value = likes_snap.value as? Int {
                        likes = likes_value
                    }
                }
                
                if(snap.childSnapshot(forPath: "comments").exists()){
                    let comments_snapshot = snap.childSnapshot(forPath: "comments")
                    for commentsSnap in comments_snapshot.children{
                        let commentSnapshot = commentsSnap as! DataSnapshot
                        
                        let commentKey = commentSnapshot.key
                        var comment_date = ""
                        var comment_text = ""
                        var poster = ""
                        
                        let comment_date_snap = commentSnapshot.childSnapshot(forPath: "comment_date")
                        if let comment_date_value = comment_date_snap.value as? String{
                            comment_date = comment_date_value
                        }
                        
                        let comment_text_snap = commentSnapshot.childSnapshot(forPath: "comment_text")
                        if let comment_text_value = comment_text_snap.value as? String {
                            comment_text = comment_text_value
                        }
                        
                        let poster_snap = commentSnapshot.childSnapshot(forPath: "poster")
                        if let poster_value = poster_snap.value as? String {
                            poster = poster_value
                        }
                        
                        if(comment_date != "" && comment_text != "" && poster != ""){
                            let newComment:comment = comment(poster: poster, comment_date: comment_date, comment_text: comment_text, database_key: commentKey)
                            
                            comments.append(newComment)
                        }
                    }
                }
                
                
                if(self.keyTitlePairs.keys.contains(postID) && post_author != "" && date_published != "" && genre != "" && story_text != "" && title != "" ){
                    let newStory:story = story(author: post_author, date_published: date_published, genre: genre, story: story_text, title: title, database_key: postID)
                    self.profileStories.append(newStory)
                    
                    if(likes != -1){
                        newStory.likes = likes
                    }
                    if(comments.count > 0){
                        newStory.comments = comments
                    }
                    
                }
            }
            self.tableView.reloadData()
        })
    }
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileStoryCell", for: indexPath) as! StoryTableViewCell

        cell.title_label.text = profileStories[indexPath.row].title
        cell.genre_label.text = profileStories[indexPath.row].genre
        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
