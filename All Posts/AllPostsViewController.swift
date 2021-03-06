//
//  AllPostsViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class AllPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, saveWasTappedDelegate {
    
    @IBOutlet weak var keywordSeachBar: UISearchBar!
    
    var saveSuccessAlert: UIAlertController?
    var saveFailureAlert: UIAlertController?
    
    var potentialIndexPath: IndexPath?
    var foundIDLibrary = ""
    var usingFilter: Bool = false
    var filteredStories: [story] = []
    
    func saveStoryWasTapped(cell: StoryTableViewCell) {
        if let indexPath = all_posts_tableview.indexPath(for: cell){
            potentialIndexPath = indexPath
            
            
            checkLibrary(completion: { foundID in
                if(foundID){
                    self.present(self.saveFailureAlert!, animated: true)
                    
                }
                else{
                    if(!self.usingFilter){ self.firebaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!).child("library").child(self.stories[indexPath.row].database_key).setValue(self.stories[indexPath.row].title)
                    }
                    else {
                        self.firebaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!).child("library").child(self.filteredStories[indexPath.row].database_key).setValue(self.filteredStories[indexPath.row].title)
                    }
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
                    
                    if(!self.usingFilter && databaseKey == self.stories[(self.potentialIndexPath?.row)!].database_key){
                        self.foundIDLibrary = databaseKey
                    }
                    if(self.usingFilter && databaseKey == self.filteredStories[(self.potentialIndexPath?.row)!].database_key){
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
    
    
    var refreshControl = UIRefreshControl()
    
    var firebaseRef: DatabaseReference?
    var stories = [story]()
    var selectedRow = -1
    
    @IBOutlet weak var all_posts_tableview: UITableView!
    
    var currentRow = -1
    var foundAuthor = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseRef = Database.database().reference()
        
        saveSuccessAlert = UIAlertController(title: "Saved To Library!", message: "", preferredStyle: .alert)
        saveSuccessAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        saveFailureAlert = UIAlertController(title: "This story is already in your library", message: "", preferredStyle: .alert)
        saveFailureAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        all_posts_tableview.delegate = self
        all_posts_tableview.dataSource = self
        keywordSeachBar.delegate = self
        
        getFirebaseStories()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        all_posts_tableview.addSubview(refreshControl)
        
    }
    
    func getFirebaseStories(){
        let storiesPath = self.firebaseRef?.child("Stories")
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
                
                
                if(post_author != "" && date_published != "" && genre != "" && story_text != "" && title != ""){
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
                    
                    self.stories.append(newStory)
                    
                }
            }
            if(self.usingFilter){
                self.filteredStories.removeAll()
                if let key = self.keywordSeachBar.text{
                    self.getFilteredStories(keyword: key)
                }
            }
            self.all_posts_tableview.reloadData()
        })
    }
    
    @objc func refresh(sender:AnyObject){
        stories.removeAll()
        getFirebaseStories()
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh(sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!usingFilter) {
            return stories.count
        }
        else {
            return filteredStories.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "readStorySegue", sender: self)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell
        cell.delegate = self
        var components: [String]
        
        currentRow = indexPath.row
        if(!usingFilter) {
            cell.genre_label.text = stories[indexPath.row].genre
            cell.title_label.text = stories[indexPath.row].title
            if(stories[indexPath.row].likes != nil){
                cell.likes_label.text = "\((stories[indexPath.row].likes)!)\nLikes"
            }
            else{
                cell.likes_label.text = "0\nLikes"
            }
            
            components = stories[indexPath.row].story.components(separatedBy: .whitespacesAndNewlines)
        }
        else {
            cell.genre_label.text = filteredStories[indexPath.row].genre
            cell.title_label.text = filteredStories[indexPath.row].title
            if(filteredStories[indexPath.row].likes != nil){
                cell.likes_label.text = "\((filteredStories[indexPath.row].likes)!)\nLikes"
            }
            else{
                cell.likes_label.text = "0\nLikes"
            }
            
            components = filteredStories[indexPath.row].story.components(separatedBy: .whitespacesAndNewlines)
        }
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
        var postersPath: DatabaseReference?
        if(!usingFilter) {
            postersPath = firebaseRef?.child("Users").child(stories[currentRow].author).child("username")
        }
        else {
            postersPath = firebaseRef?.child("Users").child(filteredStories[currentRow].author).child("username")
        }
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
    
    func getFilteredStories(keyword: String) {
        if(keyword != "") {
            usingFilter = true
            filteredStories.removeAll()
            for s in stories {
                //set keyword and title as uppercase for comparisons
                var uppercaseTarget = s.title.uppercased()
                let uppercaseKeyword = keyword.uppercased()
                var tokenizedStr = uppercaseTarget.components(separatedBy: uppercaseKeyword)
                //if title contains the token
                if(tokenizedStr.count > 1) {
                    //add the story to the list
                    filteredStories.append(s)
                }
                else {
                    //try looking for the keyword in the story
                    uppercaseTarget = s.story.uppercased()
                    tokenizedStr = uppercaseTarget.components(separatedBy: uppercaseKeyword)
                    if(tokenizedStr.count > 1) {
                        filteredStories.append(s)
                    }
                }
            }
        }
        else {
            usingFilter = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text: String = searchBar.text {
            getFilteredStories(keyword: text)
        }
        else {
            getFilteredStories(keyword: "")
        }
        self.all_posts_tableview.reloadData()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "readStorySegue"){
            let vc = segue.destination as! ReadStoryViewController
            if(!usingFilter){
                vc.current_story = stories[selectedRow]
            }
            else {
                vc.current_story = filteredStories[selectedRow]
            }
        }
    }
    

}
