//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
		
		guard let movieCell = cell as? MovieSearchTableViewCell else { return  cell }
		
		let movie = movieController.searchedMovies[indexPath.row]
		
		movieCell.movieRep = movie
		movieCell.myMovieController = myMovieController
		movieCell.delegate = self
        return movieCell
    }
	
	func simpleAlert(title: String, message: String?){
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
		present(ac, animated: true)
		
	}
	
    
    var movieController = MovieController()
	var myMovieController = MyMoviesController()
    
    @IBOutlet weak var searchBar: UISearchBar!
}


extension MovieSearchTableViewController: MovieSearchTableViewCellDelegate {
	
	
	
	
	func checkAndSave(movieRep: MovieRepresentation) {
		let title = movieRep.title
		
		let ac = UIAlertController(title: title, message: "Add this movie to MyMovies?", preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "Ok", style: .default) { action in
			guard let title = action.title else { return }
			if title == "Ok" {
				self.saveMovieToCoreData(movieRep: movieRep)
			}
		})
		
		ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
		present(ac, animated: true)
	}
	
	func saveMovieToCoreData(movieRep: MovieRepresentation) {
		let movie = Movie(title: movieRep.title)
		
		myMovieController.put(movie: movie, completion: { error in
			if let error = error {
				print("error putting movie: \(error)")
				return
			}
		})
		
		do {
			let moc = CoreDataStack.shared.mainContext
			try moc.save()
		} catch {
			NSLog("Failed to save ->: \(error)")
			return
		}
	}
}
