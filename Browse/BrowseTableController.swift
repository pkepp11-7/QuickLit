//
//  BrowseTableController.swift
//  QuickLit
//
//  Created by Patrick Keppler on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class BrowseTableController: UITableViewController {
    
    var selectedGenre: String = ""
    var genreStories = [story]()
    
    var currentRow = -1
    var foundAuthor = ""
    
    var firebaseRef: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseRef = Database.database().reference()
        
        getGenreStories()
        let backBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(backToGenre))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.title = selectedGenre
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return genreStories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell

        currentRow = indexPath.row
        
        cell.genre_label.text = genreStories[indexPath.row].genre
        cell.title_label.text = genreStories[indexPath.row].title
        if(genreStories[indexPath.row].likes != nil){
            cell.likes_label.text = "\((genreStories[indexPath.row].likes)!)"
        }
        else{
            cell.likes_label.text = "0"
        }
        
        let components = genreStories[indexPath.row].story.components(separatedBy: .whitespacesAndNewlines)
        let words = components.filter { !$0.isEmpty }
        
        if(words.count < 3000){
            cell.length_label.text = "short"
        }
        else if(words.count > 3000 && words.count < 6000){
            cell.length_label.text = "medium"
        }
        else{
            cell.length_label.text = "long"
        }
        
        
        checkUserName(completion: { foundAllBoards in
            if(foundAllBoards){
                cell.author_label.text = self.foundAuthor
            }
        })
        
        self.foundAuthor = ""
        return cell
    }
    
    func checkUserName(completion: @escaping (_ foundUserName: Bool) -> Void){
        let postersPath = firebaseRef?.child("Users").child(genreStories[currentRow].author).child("username")
        postersPath?.observe(.value, with: { snapshot in
            if(snapshot.value is NSNull) {
            } else {
                
                self.foundAuthor = snapshot.value as! String
                
                
                if(self.foundAuthor == ""){
                    completion(false)
                }
                else{
                    completion(true)
                }
            }
        })
        
    }
    
    @objc func backToGenre() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getGenreStories() {
        var firebaseRef: DatabaseReference?
        firebaseRef = Database.database().reference()
        
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
                
                
                if(post_author != "" && date_published != "" && genre == self.selectedGenre && story_text != "" && title != "" ){
                    let newStory:story = story(author: post_author, date_published: date_published, genre: genre, story: story_text, title: title, database_key: postID)
                    self.genreStories.append(newStory)
                    
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
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
