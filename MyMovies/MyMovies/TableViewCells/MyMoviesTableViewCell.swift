//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: AnyObject {
	func simpleAlert(movie: Movie?)
}

class MyMoviesTableViewCell: UITableViewCell {
	@IBAction func unwatchedToggleButton(_ sender: Any) {
		guard let delegate =  delegate else { return }
		delegate.simpleAlert(movie: movie)
	}
	
	private func setupViews() {
		guard let movie = movie, let title = movie.title else { return }
		titleLabel?.text = title
		let buttonTitle = movie.hasWatched ? "watched" : "unwatched"
		watchedToggleButton.setTitle(buttonTitle, for: .normal)
	}
	
	@IBOutlet var watchedToggleButton: UIButton!
	@IBOutlet var titleLabel: UILabel!
	var movie: Movie? { didSet {  setupViews() } }
	weak var delegate: MyMoviesTableViewCellDelegate?
}
