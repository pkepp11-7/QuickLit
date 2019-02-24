//
//  ProfileStats.swift
//  QuickLit
//
//  Created by Patrick Keppler on 2/24/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import Foundation
import Firebase

protocol StatsDelegate {
    func update()
    func updateLibrary()
}

class ProfileStats {

    var username: String = ""
    var storiesCount: Int = 0
    var totalLikes: Int = 0
    var followingCount: Int = 0
    var followerCount: Int = 0
    var userPosts: [String: String] = [:]
    var libraryPosts: [String] = []
    var libraryKeys: [String] = []
    var delegate: StatsDelegate?
    
    func getStats() {
        let firebaseRef: DatabaseReference? = Database.database().reference()
        let userid = Auth.auth().currentUser!.uid
        let idPath = firebaseRef?.child("Users").child(userid)
        idPath?.observeSingleEvent(of: .value, with: { snapshot in
            let nameSnapshot = snapshot.childSnapshot(forPath: "username")
            if let nameval = nameSnapshot.value as? String {
                print("Name:\(nameval)")
                self.username = nameval
            }
            if snapshot.childSnapshot(forPath: "posts").exists() {
                let postSnapshot = snapshot.childSnapshot(forPath: "posts")
                for posts in postSnapshot.children {
                    let postSnap = posts as! DataSnapshot
                    self.userPosts[postSnap.key] = (postSnap.value as! String)
                }
            }
            self.storiesCount = self.userPosts.count
            self.delegate?.update()
        })
    }
    
    func getLibrary() {
        let firebaseRef: DatabaseReference? = Database.database().reference()
        let userid = Auth.auth().currentUser!.uid
        let idPath = firebaseRef?.child("Users").child(userid)
        idPath?.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childSnapshot(forPath: "library").exists() {
                let postSnapshot = snapshot.childSnapshot(forPath: "library")
                for posts in postSnapshot.children {
                    let postSnap = posts as! DataSnapshot
                    self.libraryPosts.append(postSnap.value as! String)
                    self.libraryKeys.append(postSnap.key)
                }
            }
            self.delegate?.updateLibrary()
        })
    }
    
}
