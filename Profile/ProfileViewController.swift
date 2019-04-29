//
//  ProfileViewController.swift
//  QuickLit
//
//  Created by Patrick Keppler on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, StatsDelegate {
    
    var selectedRow: Int = 0
    var myStats: ProfileStats = ProfileStats()
    var myLibrary: ProfileStats = ProfileStats()
    var imageURL: String?
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var favoritesTable: UITableView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    
    @IBOutlet weak var storiesCount: UIButton!
    
    @IBOutlet weak var likesCount: UIButton!
    
    @IBOutlet weak var followingCount: UIButton!
    
    @IBOutlet weak var followerCount: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var aboutTitleLable: UILabel!
    
    @IBOutlet weak var cellStoryLabel: UILabel!
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
                performSegue(withIdentifier: "returnHome", sender: self)
        }
            catch let error as NSError {
                print(error.localizedDescription)
            }
    }
    
    
    @IBOutlet weak var profileContent: UIScrollView!
   
    
    override func viewDidAppear(_ animated: Bool) {
        print("performing data refresh")
        refresh(sender: self)
    }
    
    
    @IBAction func storiesCounterPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toStoriesList", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var minValue = 3
        if(myLibrary.libraryPosts.count < minValue) {
            minValue = myLibrary.libraryPosts.count
        }
        return minValue
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"favoritesSmallCell", for: indexPath) as! FavoritesSmallCell
        cell.storyTitle.text = myLibrary.libraryPosts[indexPath.row]
        return cell
    }
    
    func update() {
        self.storiesCount.setTitle(String(myStats.storiesCount), for: .normal)
        self.usernameLabel.text = myStats.username
        self.aboutTitleLable.text = "About \(myStats.username)"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.isUserInteractionEnabled = true
        initProifilePictureInteraction()
        initProfileImage()
        // Do any additional setup after loading the view.
        likesCount.setTitle("0", for: .normal)
        followingCount.setTitle("0", for: .normal)
        followerCount.setTitle("0", for: .normal)
        myStats.delegate = self
        myStats.getStats()
        myLibrary.delegate = self
        myLibrary.getLibrary()
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        favoritesTable.tableFooterView = UIView(frame: .zero)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        profileContent.addSubview(refreshControl)
        
    }
    
    @objc func refresh(sender: AnyObject) {
        print("refresh started")
        myLibrary.libraryKeys = []
        myLibrary.libraryPosts = []
        myLibrary.getLibrary()
        myStats.userPosts = [:]
        myStats.getStats()
        refreshControl.endRefreshing()
        
    }
    
    
    
    func updateLibrary() {
        favoritesTable.reloadData()
    }

    @IBAction func morePressed(_ sender: Any) {
        performSegue(withIdentifier: "toLibraryTable", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "toStoriesList") {
            let storiesListVC = segue.destination as! ProfileStoryTableController
            //print(myStats.userPosts)
            storiesListVC.keyTitlePairs = myStats.userPosts
        }
        
        if(segue.identifier == "toLibraryTable") {
            let libraryTableVc = segue.destination as! LibraryTableViewController
            libraryTableVc.libraryKeys = myLibrary.libraryKeys
        }
        
        if(segue.identifier == "returnHome") {
            let rootVC = segue.destination
        }
        
    }

    func initProifilePictureInteraction() {
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
    }
    
    @objc func handleSelectProfileImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            self.present(picker, animated: true, completion: nil)
        }
        else {
            print("photo library not available")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImage.image = editedImage
            if let resizedImage = resizeImage(image:editedImage, newWidth: 90) {
                saveProfileImage(image: resizedImage)
            }
            else {
                saveProfileImage(image: editedImage)
            }
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            profileImage.image = originalImage
            if let resizedImage = resizeImage(image: originalImage, newWidth: 90) {
                saveProfileImage(image: resizedImage)
            }
            else {
                saveProfileImage(image: originalImage)
            }
        }
        else {
            print("Error in selecting image.")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func initProfileImage() {
        if let url = imageURL {
            if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
                profileImage.image = imageFromCache
            }
        }
        else {
            getProfileImage()
        }
    }
    
    func saveProfileImage(image: UIImage) {
        //if user has id
        if let userId = Auth.auth().currentUser?.uid {
            //get the location in storage for profile photo
            let storagePath = Storage.storage().reference().child(userId + ".png")
            //if the image can be saved as PNG
            print("performing png check")
            if let imagePNG = image.pngData() {
                print("done performing png check")
                //upload the image, get the image url
                let uploadTask = storagePath.putData(imagePNG, metadata: nil) { (metadata, error) in
                    if let uploadError = error {
                        print("Upload Error Ocurred\n\n\n")
                        print(uploadError)
                        return
                    }
                    else {
                        print("Upload Succeeded\n\n\n")
                        if let size = metadata?.size {
                            print(size)
                        }
                    }
                    storagePath.downloadURL{ (url, error2) in
                        if let urlError = error2 {
                            print(urlError)
                            return
                        }
                        else {
                            self.imageURL = url?.absoluteString
                            //if url is not nil
                            if let url = self.imageURL {
                                self.saveProfileImageURL(userId: userId, url: url)
                            }
                            self.imageCache.setObject(image, forKey: self.imageURL! as AnyObject)
                        }
                    }
                }
            }
        }
    }
    
    func saveProfileImageURL(userId: String, url: String) {
        let firebaseRef = Database.database().reference()
        let childUpdates = ["Users/\(userId)/profile_image_url": url]
        firebaseRef.updateChildValues(childUpdates)
    }
    
    
    func getProfileImage() {
        let firebaseRef = Database.database().reference()
        if let userId = Auth.auth().currentUser?.uid {
            firebaseRef.child("Users/\(userId)/profile_image_url").observe(.value, with: { (snapshot) in
                if let urlString = snapshot.value as? String {
                    let storageRef = Storage.storage().reference(forURL: urlString)
                    storageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
                        if let downloadError = error {
                            print("Download error:\n\(downloadError)")
                        }
                        else {
                            if let imageToCache = UIImage(data: data!) {
                                self.imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                                self.profileImage.image = imageToCache
                            }
                        }
                    }
                }
            })
        }
    }
    
    //helpful code from stackoverflow.com to resize image, maintaining aspect ratio
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        //get a scale factor
        let scale = newWidth / image.size.width
        let newHeight = scale * image.size.height
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
