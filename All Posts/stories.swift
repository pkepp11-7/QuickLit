//
//  stories.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import Foundation


class story {
    
    var author: String = ""
    var date_published: String = ""
    var genre: String = ""
    var story: String = ""
    var title: String = ""
    var database_key: String = ""
    var likes: Int?
    var comments: Array<comment>?
    
    
    init(author: String, date_published: String, genre: String, story: String, title: String, database_key: String){
        self.author = author
        self.date_published = date_published
        self.genre = genre
        self.story = story
        self.title = title
        self.database_key = database_key
    }
}
