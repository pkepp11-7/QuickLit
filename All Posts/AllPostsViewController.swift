//
//  AllPostsViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class AllPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var firebaseRef: DatabaseReference?
    var stories = [story]()
    
    @IBOutlet weak var all_posts_tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseRef = Database.database().reference()
        
        all_posts_tableview.delegate = self
        all_posts_tableview.dataSource = self
        
        
        let storiesPath = self.firebaseRef?.child("Stories")
        storiesPath?.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                
                let postID = snap.key
                var post_author = ""
                var date_published = ""
                var genre = ""
                var story_text = ""
                var title = ""
                
                let post_author_snap = snapshot.childSnapshot(forPath: "author")
                if let post_author_value = post_author_snap.value as? String {
                    post_author = post_author_value
                }
                
                let date_published_snap = snapshot.childSnapshot(forPath: "date_published")
                if let date_published_value = date_published_snap.value as? String {
                    date_published = date_published_value
                }
                
                let genre_snap = snapshot.childSnapshot(forPath: "genre")
                if let genre_value = genre_snap.value as? String {
                    genre = genre_value
                }
                
                let story_snap = snapshot.childSnapshot(forPath: "story")
                if let story_value = story_snap.value as? String {
                    story_text = story_value
                }
                
                let title_snap = snapshot.childSnapshot(forPath: "title")
                if let title_value = title_snap.value as? String {
                    title = title_value
                }
                
                if(post_author != "" && date_published != "" && genre != "" && story_text != "" && title != ""){
                    let newStory:story = story(author: post_author, date_published: date_published, genre: genre, story: story_text, title: title, database_key: postID)
                    
                    self.stories.append(newStory)
                    
                }
            }
            self.all_posts_tableview.reloadData()
        })
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell
        
        cell.genre_label.text = stories[indexPath.row].genre
        cell.title_label.text = stories[indexPath.row].title
        
        return cell
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
