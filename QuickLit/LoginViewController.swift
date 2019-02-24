//
//  LoginViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    var incompleteFieldsAlert: UIAlertController?
    var wrongEmailOrPasswordAlert: UIAlertController?
    
    @IBOutlet weak var email_textfield: UITextField!
    @IBOutlet weak var password_textfield: UITextField!
    
    @IBOutlet weak var create_account_button: UIButton!
    
    @IBOutlet weak var log_in_button: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        email_textfield.delegate = self
        password_textfield.delegate = self
        
        log_in_button.layer.cornerRadius = 10
        log_in_button.layer.borderWidth = 1
        log_in_button.layer.borderColor = UIColor.clear.cgColor
        
        
        incompleteFieldsAlert = UIAlertController(title: "Please complete all fields", message: "", preferredStyle: .alert)
        incompleteFieldsAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        wrongEmailOrPasswordAlert = UIAlertController(title: "You have entered the wrong email or password", message: "", preferredStyle: .alert)
        wrongEmailOrPasswordAlert!.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "done action"), style: .default, handler: nil))
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserIsSignedIn()
    }
    
    
    @IBAction func createAccountAction(_ sender: UIButton) {
        performSegue(withIdentifier: "createAccountSegue", sender: self)
    }
    
    @IBAction func logInButton(_ sender: UIButton) {
        if(email_textfield.hasText && password_textfield.hasText){
            Auth.auth().signIn(withEmail: email_textfield.text!, password: password_textfield.text!) {
                (user, error) in
                if(user != nil){
                    self.performSegue(withIdentifier: "completeLogInSegue", sender: self)
                    self.email_textfield.text = ""
                    self.password_textfield.text = ""
                }
                if(error != nil){
                    self.present(self.wrongEmailOrPasswordAlert!, animated: true)
                }
                
            }
        }
        else{
            self.present(self.incompleteFieldsAlert!, animated: true)
        }
    }
    
    func checkIfUserIsSignedIn(){
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "completeLogInSegue", sender: self)
        }
        else{
            print("not signed in")
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
