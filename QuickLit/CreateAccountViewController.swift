//
//  CreateAccountViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    
    var incompleteFieldsAlert: UIAlertController?
    var errorAlert: UIAlertController?
    
    
    
    var firebaseRef: DatabaseReference?
    @IBOutlet weak var username_textfield: UITextField!
    
    @IBOutlet weak var email_textfield: UITextField!
    
    
    @IBOutlet weak var password_textfield: UITextField!
    
    @IBOutlet weak var create_and_continue_button: UIButton!
    
    @IBOutlet weak var close_button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseRef = Database.database().reference()
        
        username_textfield.delegate = self
        email_textfield.delegate = self
        password_textfield.delegate = self
        
        create_and_continue_button.layer.cornerRadius = 10
        create_and_continue_button.layer.borderWidth = 1
        create_and_continue_button.layer.borderColor = UIColor.clear.cgColor
        
        close_button.layer.cornerRadius = 10
        close_button.layer.borderWidth = 1
        close_button.layer.borderColor = UIColor.clear.cgColor
        
        
        incompleteFieldsAlert = UIAlertController(title: "Please complete all fields", message: "", preferredStyle: .alert)
        incompleteFieldsAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        errorAlert = UIAlertController(title: "There was an error making the account, try again later", message: "", preferredStyle: .alert)
        errorAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAndContinueAction(_ sender: UIButton) {
        if(username_textfield.hasText && email_textfield.hasText && password_textfield.hasText){
            Auth.auth().createUser(withEmail: email_textfield.text!, password: password_textfield.text!) { (authResult, error) in
                if(authResult != nil){
                    
                    let todaysDateString = getTodaysDate()
                    let firebaseFriendlyDate = todaysDateString.replacingOccurrences(of: "/", with: "-")
                    
                    let fbNewUser = self.firebaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!)
                    fbNewUser?.child("username").setValue(self.username_textfield.text)
                    fbNewUser?.child("creation_date").setValue(firebaseFriendlyDate)
                    fbNewUser?.child("likes").setValue(0)
                  
                    Auth.auth().signIn(withEmail: self.email_textfield.text!, password: self.password_textfield.text!) {
                        (user, error) in
                        if(user != nil){
                            
                        }
                        if(error != nil){
                            print("there was an error")
                            print(error.debugDescription)
                        }
                    }
                    
                    self.email_textfield.text = ""
                    self.password_textfield.text = ""
                    self.performSegue(withIdentifier: "completeCreateAccountSegue", sender: self)
                    
                }
                if(error != nil){
                    self.present(self.errorAlert!, animated: true)
                }
            }
        }
        else{
            self.present(self.incompleteFieldsAlert!, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
