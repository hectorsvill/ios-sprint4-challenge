//
//  Movie+Conveniece.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData
extension Movie {
	
	convenience init (title: String, identifier: UUID = UUID(), hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		self.init(context: context)
		self.title = title
		self.identifier = identifier
		self.hasWatched = hasWatched
	}
	
	convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
		guard let identifier = movieRepresentation.identifier, let hasWatched = movieRepresentation.hasWatched else { return nil}
		self.init(title: movieRepresentation.title, identifier: identifier, hasWatched: hasWatched, context: context)
	}
	
	var movieRepresentation: MovieRepresentation? {
		guard let title = title, let identifier = identifier else { return nil }
		return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
	}
}
