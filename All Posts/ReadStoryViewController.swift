//
//  ReadStoryViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class ReadStoryViewController: UIViewController {
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseRef = Database.database().reference()
        
        
        checkUserName(completion: { foundAllBoards in
            if(foundAllBoards){
                self.genre_label.text = self.current_story?.genre
                self.author_label.text = self.author_name
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
        let likesCount = firebaseRef!.child("Stories").child((current_story?.database_key)!).child("likes")
        likesCount.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
            
            var currentCount = currentData.value as? Int ?? 0
            currentCount += 1
            currentData.value = currentCount
            DispatchQueue.main.async {
                self.total_likes_label.text = "\((currentData.value)!)"
            }
            
            return TransactionResult.success(withValue: currentData)
        })
    }
    
    @IBAction func addToLibraryAction(_ sender: UIButton) {
        
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(current_story?.comments == nil){
            return 0
        }
        else{
            return (current_story?.comments?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    */
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toCommentSegue"){
            let vc = segue.destination as! CreateCommentViewController
            
            vc.current_story = current_story
        }
    }
 

}
