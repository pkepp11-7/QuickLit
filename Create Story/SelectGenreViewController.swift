//
//  SelectGenreViewController.swift
//  QuickLit
//
//  Created by Angel castaneda on 2/23/19.
//  Copyright © 2019 Angel castaneda. All rights reserved.
//

import UIKit

protocol selectGenreProtocol {
    func didSelectGenre(genre: String)
}

class SelectGenreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var genres = ["Action/Adventure","Comedy","Crime", "Drama", "Fantasy", "Historical","Horror", "Mystery", "Romance", "Science Fiction"]
    
    
    @IBOutlet weak var genre_tableview: UITableView!
    @IBOutlet weak var close_button: UIButton!
    
    var selectGenreDelegate: selectGenreProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        genre_tableview.delegate = self
        genre_tableview.dataSource = self
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectGenreDelegate?.didSelectGenre(genre: genres[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath) as! GenreTableViewCell
        
        cell.genre_label.text = genres[indexPath.row]
        
        return cell
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
