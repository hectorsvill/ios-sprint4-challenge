//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: AnyObject {
	func checkAndSave(movieRep: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {

	@IBAction func AddMovieButton(_ sender: Any) {
		guard let movieRep = movieRep else { return }
		delegate?.checkAndSave(movieRep: movieRep)
	}
	
	private func setupViews() {
		titleLable?.text = movieRep?.title
	}
	
	@IBOutlet var titleLable: UILabel!
	var movieRep: MovieRepresentation? { didSet { setupViews() } }
	var myMovieController: MyMoviesController?
	weak var delegate: MovieSearchTableViewCellDelegate?
}
