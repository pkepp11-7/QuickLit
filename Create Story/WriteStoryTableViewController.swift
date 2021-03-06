//
//  WriteStoryTableViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase


class WriteStoryTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, selectGenreProtocol {
    
    var completeFieldsAlert: UIAlertController?
    var publishedAlert: UIAlertController?

    @IBOutlet weak var publish_button: UIBarButtonItem!
    @IBOutlet weak var story_textview: UITextView!
    @IBOutlet weak var title_textfield: UITextField!
    
    var pickedGenre = "None"
    var firebaseRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title_textfield.delegate = self
        story_textview.delegate = self
        
        firebaseRef = Database.database().reference()
        
        completeFieldsAlert = UIAlertController(title: "Complete all fields before publishing", message: "", preferredStyle: .alert)
        completeFieldsAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        publishedAlert = UIAlertController(title: "Published!", message: "", preferredStyle: .alert)
        publishedAlert?.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
    }
    
    func didSelectGenre(genre: String){
        pickedGenre = genre
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.cellForRow(at: indexPath)?.textLabel!.text = genre
        
    }
    
    
    @IBAction func publishAction(_ sender: UIBarButtonItem) {
        if(title_textfield.hasText && story_textview.hasText && pickedGenre != "None"){
            
            let todaysDateString = getTodaysDate()
            let firebaseFriendlyDate = todaysDateString.replacingOccurrences(of: "/", with: "-")
            
            let fbNewPost = self.firebaseRef?.child("Stories").childByAutoId()
            
            fbNewPost?.child("author").setValue(Auth.auth().currentUser?.uid)
            fbNewPost?.child("genre").setValue(pickedGenre)
            fbNewPost?.child("title").setValue(title_textfield.text)
            fbNewPost?.child("story").setValue(story_textview.text)
            fbNewPost?.child("date_published").setValue(firebaseFriendlyDate)
            
            let newPostKey = fbNewPost?.key
            
            
            
            let fbUserPosts = self.firebaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!).child("posts")
            
            fbUserPosts?.child(newPostKey!).setValue(title_textfield.text)
            
            
            pickedGenre = "None"
            title_textfield.text = ""
            story_textview.text = ""
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel!.text = "None"
            
            title_textfield.resignFirstResponder()
            story_textview.resignFirstResponder()
            self.present(self.publishedAlert!, animated: true)
            
            
        }
        else{
            self.present(self.completeFieldsAlert!, animated: true)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0){
            performSegue(withIdentifier: "selectGenreSegue", sender: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectGenreSegue"){
            let vc = segue.destination as! SelectGenreViewController
            vc.selectGenreDelegate = self
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for inputViews in self.view.subviews{
            if((inputViews.isKind(of: UITextField.self) || (inputViews.isKind(of: UITextView.self))) && inputViews.isFirstResponder){
                inputViews.resignFirstResponder()
            }
        }
    }
 

}
