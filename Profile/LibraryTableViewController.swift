//
//  LibraryTableViewController.swift
//  QuickLit
//
//  Created by Patrick Keppler on 2/24/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class LibraryTableViewController: UITableViewController, saveWasTappedDelegate{
    
    func saveStoryWasTapped(cell: StoryTableViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell){
            potentialIndexPath = indexPath
            
            
            checkLibrary(completion: { foundID in
                if(foundID){
                    self.present(self.saveFailureAlert!, animated: true)
                    
                }
                else{
                    self.firebaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!).child("library").child(self.libraryStories[indexPath.row].database_key).setValue(self.libraryStories[indexPath.row].title)
                    self.present(self.saveSuccessAlert!, animated: true)
                }
                
            })
            foundIDLibrary = ""
        }
    }
    
    func checkLibrary(completion: @escaping (_ foundID: Bool) -> Void){
        let libraryPath = firebaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!).child("library")
        libraryPath?.observe(.value, with: { snapshot in
            if(snapshot.value is NSNull) {
                completion(false)
                
            } else {
                for story in snapshot.children{
                    let storySnap = story as! DataSnapshot
                    
                    let databaseKey = storySnap.key
                    
                    if(databaseKey == self.libraryStories[(self.potentialIndexPath?.row)!].database_key){
                        self.foundIDLibrary = databaseKey
                    }
                }
                
                
                if(self.foundIDLibrary == ""){
                    completion(false)
                }
                else{
                    completion(true)
                }
            }
        })
    }
    
    var saveSuccessAlert: UIAlertController?
    var saveFailureAlert: UIAlertController?
    
    var potentialIndexPath: IndexPath?
    var foundIDLibrary = ""
    
    var libraryKeys: [String] = []
    var libraryStories: [story] = []
    var foundAuthor: String = ""
    var currentRow: Int = 0
    
    var firebaseRef: DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        firebaseRef = Database.database().reference()
        
        getLibraryStories()
        
        saveSuccessAlert = UIAlertController(title: "Saved To Library!", message: "", preferredStyle: .alert)
        saveSuccessAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        saveFailureAlert = UIAlertController(title: "This story is already in your library", message: "", preferredStyle: .alert)
        saveFailureAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return libraryStories.count
    }

    override func viewDidAppear(_ animated: Bool) {
        getLibraryStories()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell
        currentRow = indexPath.row
        
        cell.delegate = self
        cell.genre_label.text = libraryStories[indexPath.row].genre
        cell.title_label.text = libraryStories[indexPath.row].title
        if(libraryStories[indexPath.row].likes != nil){
            cell.likes_label.text = "\((libraryStories[indexPath.row].likes)!)\nLikes"
        }
        else{
            cell.likes_label.text = "0\nLikes"
        }
        
        let components = libraryStories[indexPath.row].story.components(separatedBy: .whitespacesAndNewlines)
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
                cell.author_label.text = "By: \(self.foundAuthor)"
            }
        })
        
        self.foundAuthor = ""

        return cell
    }
    
    
    func checkUserName(completion: @escaping (_ foundUserName: Bool) -> Void){
        let firebaseRef: DatabaseReference? = Database.database().reference()
        let postersPath = firebaseRef?.child("Users").child(libraryStories[currentRow].author).child("username")
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
    
    func getLibraryStories() {
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
                if let genre_value = genre_snap.value as? String {
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
                
                
                if(self.libraryKeys.contains(postID) && post_author != "" && date_published != "" && genre != "" && story_text != "" && title != ""){
                    let newStory:story = story(author: post_author, date_published: date_published, genre: genre, story: story_text, title: title, database_key: postID)
                    
                    if(likes != -1){
                        newStory.likes = likes
                    }
                    else{
                        newStory.likes = 0
                    }
                    if(comments.count > 0){
                        newStory.comments = comments
                    }
                    
                    self.libraryStories.append(newStory)
                    
                    
                }
            }
            
            self.tableView.reloadData()
        })
        
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

}
