//
//  comments.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import Foundation


class comment {
    
    var poster: String = ""
    var comment_date: String = ""
    var comment_text: String = ""
    var database_key: String = ""
    var likes: Int?
    
    
    init(poster: String, comment_date: String, comment_text: String, database_key: String){
        self.poster = poster
        self.comment_date = comment_date
        self.comment_text = comment_text
        self.database_key = database_key
    }
}
