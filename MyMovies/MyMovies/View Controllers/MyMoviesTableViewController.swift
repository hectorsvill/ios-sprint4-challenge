//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		myMovieController.fetchMoviesFromServer { error in
			if let error = error {
				print("Error fetching moives in MyMoviesTableViewController: \(error) ")
				return
			}
			
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if fetchedResultController.sections?[section].name == "0" {
			return "Unwatched"
		} else {
			return "Watched"
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultController.sections?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultController.sections?[section].numberOfObjects ?? 0
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath)
		
		guard let myMovieCell = cell as? MyMoviesTableViewCell else { return cell }
		let movie = fetchedResultController.object(at: indexPath)
		myMovieCell.movie = movie
		myMovieCell.delegate = self
		return myMovieCell
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let movie = fetchedResultController.object(at: indexPath)
			let moc = CoreDataStack.shared.mainContext

			myMovieController.deleteMovieFromServer(movie: movie) { error in
				if let error = error {
					print("Error deleting movie from server: \(error)")
					return
				}
			}
		
			moc.performAndWait {
				moc.delete(movie)
			}
			
			do {
				try moc.save()
			} catch {
				print("Error deleting from store: \(error)")
			}
		
			self.tableView.reloadData()
		}
		
	}
	
	let myMovieController = MyMoviesController()
	
	lazy var fetchedResultController: NSFetchedResultsController<Movie> = {
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
		let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "hasWatched", cacheName: nil)
		fetchResultController.delegate = self
		
		do {
			try fetchResultController.performFetch()
		} catch {
			NSLog("Error performing initial fetch for frc")
		}
		
		return fetchResultController
	}()
	
}


extension MyMoviesTableViewController {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else { return }
			tableView.deleteRows(at: [indexPath], with: .automatic)
		case .move:
			guard let indexPath = indexPath,
				let newIndexPath = newIndexPath else { return }
			tableView.deleteRows(at: [indexPath], with: .automatic)
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .update:
			guard let indexPath = indexPath else { return }
			tableView.reloadRows(at: [indexPath], with: .automatic)
		@unknown default:
			print("uknow default")
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange sectionInfo: NSFetchedResultsSectionInfo,
					atSectionIndex sectionIndex: Int,
					for type: NSFetchedResultsChangeType) {
		
		switch type {
		case .insert:
			let indexSet = IndexSet(integer: sectionIndex)
			tableView.insertSections(indexSet, with: .automatic)
		case .delete:
			let indexSet = IndexSet(integer: sectionIndex)
			tableView.deleteSections(indexSet, with: .automatic)
		default:
			break
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	
}

extension MyMoviesTableViewController: MyMoviesTableViewCellDelegate {
	func simpleAlert(movie: Movie?) {
		guard let movie = movie,
			let title = movie.title
			else { return }
		
		let message = movie.hasWatched ? "unwatched" : "watched"
		
		let ac = UIAlertController(title: title.uppercased(), message: "\(message) movie", preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
		ac.addAction(UIAlertAction(title: "OK", style: .default){ action in
			guard let title = action.title else { return }
			
			if title == "OK" {
				self.updateMovieHasWatched(movie: movie)
			}
			
		})
		present(ac, animated: true)
	}
	
	func updateMovieHasWatched(movie: Movie?) {
		if let movie = movie {
			movie.hasWatched.toggle()
			myMovieController.put(movie: movie, completion: { error in
				if let error = error {
					print("error updating movie: \(error)")
					return
				}
			})
		}
		
		do {
			let moc = CoreDataStack.shared.mainContext
			try moc.save()
		} catch {
			NSLog("Error updating movie to moc: \(error)")
		}
	}
	
}
