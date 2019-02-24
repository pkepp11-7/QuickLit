//
//  StoryTableViewCell.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {

    @IBOutlet weak var genre_label: UILabel!
    
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var save_button: UIButton!
    
    @IBOutlet weak var likes_label: UILabel!
    
    @IBOutlet weak var length_label: UILabel!
    
    @IBOutlet weak var author_label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func saveAction(_ sender: UIButton) {
    }
    
    
    
    
    
}
