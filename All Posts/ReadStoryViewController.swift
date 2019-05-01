//
//  ReadStoryViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class ReadStoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    var saveSuccessAlert: UIAlertController?
    var saveFailureAlert: UIAlertController?
    
    @IBOutlet weak var content_scrollview: UIScrollView!
    
    @IBOutlet weak var author_label: UILabel!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var genre_label: UILabel!
    
    
    @IBOutlet weak var story_textview: UITextView!
    
    @IBOutlet weak var total_likes_label: UILabel!
    
    @IBOutlet weak var like_button: UIButton!
    
    @IBOutlet weak var add_to_libary_button: UIButton!
    
    @IBOutlet weak var add_comment_button: UIButton!
    
    
    @IBOutlet weak var comments_collectionview: UICollectionView!
    
    
    var current_story: story?
    var firebaseRef: DatabaseReference?
    
    
    var author_name = ""
    
    var found_poster = ""
    var foundIDLibrary = ""
    var isLiked: Bool = false
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        saveSuccessAlert = UIAlertController(title: "Saved To Library!", message: "", preferredStyle: .alert)
        saveSuccessAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        saveFailureAlert = UIAlertController(title: "This story is already in your library", message: "", preferredStyle: .alert)
        saveFailureAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        like_button.layer.cornerRadius = 10
        like_button.layer.borderWidth = 1
        like_button.layer.borderColor = UIColor.clear.cgColor
        
        add_comment_button.layer.cornerRadius = 10
        add_comment_button.layer.borderWidth = 1
        add_comment_button.layer.borderColor = UIColor.clear.cgColor
        
        add_to_libary_button.layer.cornerRadius = 10
        add_to_libary_button.layer.borderWidth = 1
        add_to_libary_button.layer.borderColor = UIColor.clear.cgColor
        

        content_scrollview.contentSize = CGSize(width: self.view.frame.size.width, height: 900)
        
        firebaseRef = Database.database().reference()
        
        comments_collectionview.delegate = self
        comments_collectionview.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        content_scrollview.addSubview(refreshControl)
        
        checkUserName(completion: { foundAllBoards in
            if(foundAllBoards){
                self.genre_label.text = self.current_story?.genre
                self.author_label.text = "By: \(self.author_name)"
                self.title_label.text = self.current_story?.title
                
                self.story_textview.text = self.current_story?.story
                
                if(self.current_story?.likes == nil){
                    self.total_likes_label.text = "0"
                }
                else{
                    self.total_likes_label.text = "\((self.current_story?.likes!)!)"
                }
            }
        })
        initLikes()
    }
    
    @objc func refresh(sender:AnyObject){
        
        let storiesPath = self.firebaseRef?.child("Stories").child((current_story?.database_key)!)
        storiesPath?.observeSingleEvent(of: .value, with: { snapshot in
            let postID = snapshot.key
            var post_author = ""
            var date_published = ""
            var genre = ""
            var story_text = ""
            var title = ""
            var likes = -1
            var comments = [comment]()
            
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
            
            if(snapshot.childSnapshot(forPath: "likes").exists()){
                let likes_snap = snapshot.childSnapshot(forPath: "likes")
                if let likes_value = likes_snap.value as? Int {
                    likes = likes_value
                }
            }
            if(snapshot.childSnapshot(forPath: "comments").exists()){
                let comments_snapshot = snapshot.childSnapshot(forPath: "comments")
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
                if(comments.count > 0){
                    newStory.comments = comments
                }
                
                self.current_story = newStory
            }
            self.comments_collectionview.reloadData()
            
            if(self.current_story?.likes == nil){
                self.total_likes_label.text = "0"
            }
            else{
                self.total_likes_label.text = "\((self.current_story?.likes!)!)"
            }
            
            
            self.refreshControl.endRefreshing()
        })
    }
    
    
    func checkUserName(completion: @escaping (_ foundUserName: Bool) -> Void){
        let postersPath = firebaseRef?.child("Users").child((current_story?.author)!).child("username")
        postersPath?.observe(.value, with: { snapshot in
            if(snapshot.value is NSNull) {
            } else {
                
                self.author_name = snapshot.value as! String
                
                
                if(self.author_name == ""){
                    completion(false)
                }
                else{
                    completion(true)
                }
            }
        })
        
    }
    
    
    @IBAction func addCommentAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toCommentSegue", sender: self)
    }
    
    
    @IBAction func likeAction(_ sender: UIButton) {
        if(isLiked) {
            isLiked = false
        }
        else {
            isLiked = true
        }
        let likesCount = firebaseRef!.child("Stories").child((current_story?.database_key)!).child("likes")
        likesCount.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
            var currentCount = currentData.value as? Int ?? 0
            if(self.isLiked) {
                currentCount += 1
            }
            else {
                currentCount -= 1
            }
            currentData.value = currentCount
            DispatchQueue.main.async {
                self.total_likes_label.text = "\((currentData.value)!)"
                if(self.isLiked) {
                    self.like_button.setTitle("Unlike", for: .normal)
                }
                else {
                    self.like_button.setTitle("Like", for: .normal)
                }
            }
            return TransactionResult.success(withValue: currentData)
        })
        
        let userLikes = firebaseRef!.child("Users").child((current_story?.author)!).child("likes")
        userLikes.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
            
            var currentCount = currentData.value as? Int ?? 0
            currentCount += 1
            currentData.value = currentCount
            
            
            return TransactionResult.success(withValue: currentData)
        })
        
        if let userId = Auth.auth().currentUser?.uid {
            let likesList = firebaseRef!.child("Users").child((userId)).child("likes_list")
            likesList.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
                
                var list = currentData.value as? [String] ?? []
                if let key = self.current_story?.database_key {
                    if(self.isLiked) {
                        list.append(key)
                    }
                    else {
                        if let removeIndex = list.firstIndex(of: key) {
                            list.remove(at: removeIndex)
                        }
                    }
                }
                currentData.value = list
                return TransactionResult.success(withValue: currentData)
            })
        }
    }
    
    @IBAction func addToLibraryAction(_ sender: UIButton) {
        checkLibrary(completion: { foundID in
            if(foundID){
                self.present(self.saveFailureAlert!, animated: true)
                
            }
            else{
                self.firebaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!).child("library").child((self.current_story?.database_key)!).setValue(self.current_story?.title)
                self.present(self.saveSuccessAlert!, animated: true)
            }
            
        })
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
                    
                    if(databaseKey == self.current_story?.database_key){
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(current_story?.comments == nil){
            return 1
        }
        else{
            return (current_story?.comments?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath) as! CommentCollectionViewCell
        if(current_story?.comments != nil){
            cell.comment_textview.text = current_story?.comments![indexPath.row].comment_text
            cell.comment_date_label.text = current_story?.comments![indexPath.row].comment_date
            
            checkCommentUsername(completion: { foundAllBoards in
                if(foundAllBoards){
                    cell.poster_label.text = self.found_poster
                }
            })
            
            found_poster = ""
            
        }
        else{
            cell.comment_textview.text = "There are currently no comments on this story"
            cell.comment_date_label.text = ""
            cell.poster_label.text = ""
        }
        return cell
        
    }
    
    func checkCommentUsername(completion: @escaping (_ foundUserName: Bool) -> Void){
        let postersPath = firebaseRef?.child("Users").child((current_story?.author)!).child("username")
        postersPath?.observe(.value, with: { snapshot in
            if(snapshot.value is NSNull) {
            } else {
                
                self.found_poster = snapshot.value as! String
                
                
                if(self.found_poster == ""){
                    completion(false)
                }
                else{
                    completion(true)
                }
            }
        })
        
    }
 
    func initLikes() {
        if let userId = Auth.auth().currentUser?.uid {
            let likesPath = firebaseRef?.child("/Users/").child(userId).child("likes_list")
            likesPath?.observe(.value, with: { snapshot in
                if let likesList = snapshot.value as? [String] {
                    for storyId in likesList {
                        if(storyId == self.current_story?.database_key) {
                            self.isLiked = true
                            break
                        }
                    }
                    if(!self.isLiked) {
                        self.like_button.setTitle("Like", for: .normal)
                    }
                }
            })
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toCommentSegue"){
            let vc = segue.destination as! CreateCommentViewController
            
            vc.current_story = current_story
        }
    }
 

}
