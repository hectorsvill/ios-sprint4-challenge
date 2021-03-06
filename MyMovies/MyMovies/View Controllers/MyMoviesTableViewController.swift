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
			}
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
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
		myMovieCell.myMovieController = myMovieController
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
				
				moc.performAndWait {
					moc.delete(movie)
				}
			}
		
			do {
				try moc.save()
			} catch {
				print("Error deleting from store: \(error) ")
			}
		
			self.tableView.reloadData()
		}
		
		
	}
	
	
	let myMovieController = MyMoviesController()
	
	lazy var fetchedResultController: NSFetchedResultsController<Movie> = {
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
		let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
															   managedObjectContext: CoreDataStack.shared.mainContext,
															   sectionNameKeyPath: "hasWatched",
															   cacheName: nil)
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
