//
//  CreateCommentViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class CreateCommentViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var close_button: UIButton!
    
    @IBOutlet weak var comment_text: UITextView!
    @IBOutlet weak var submit_button: UIButton!
    
    var firebaseRef: DatabaseReference?
    var current_story: story?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseRef = Database.database().reference()
        
        comment_text.delegate = self
        
        close_button.layer.cornerRadius = 10
        close_button.layer.borderWidth = 1
        close_button.layer.borderColor = UIColor.clear.cgColor
        
        submit_button.layer.cornerRadius = 10
        submit_button.layer.borderWidth = 1
        submit_button.layer.borderColor = UIColor.clear.cgColor
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        if(comment_text.hasText){
            
            let todaysDateString = getTodaysDate()
            let firebaseFriendlyDate = todaysDateString.replacingOccurrences(of: "/", with: "-")
            
            let fbNewComment = firebaseRef?.child("Stories").child((current_story?.database_key)!).child("comments").childByAutoId()
            fbNewComment?.child("comment_text").setValue(comment_text.text)
            fbNewComment?.child("comment_date").setValue(firebaseFriendlyDate)
            fbNewComment?.child("poster").setValue(Auth.auth().currentUser?.uid)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for inputViews in self.view.subviews{
            if((inputViews.isKind(of: UITextField.self) || (inputViews.isKind(of: UITextView.self))) && inputViews.isFirstResponder){
                inputViews.resignFirstResponder()
            }
        }
    }

}
