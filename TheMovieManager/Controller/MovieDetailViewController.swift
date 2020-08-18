//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        
        
        // not every movie has a poster path (this is optional) so make sure it is not nil before downloadint the image
        if let posterPath = movie.posterPath {
            TMDBClient.downloadPosterImage(posterPath: posterPath) {(data, error) in
                // check if we got data back
                guard let data = data else {
                    return
                }
                // if so, convert it to a UI image
                let image = UIImage(data: data)
                // set it to the image contained in the image view
                self.imageView.image = image
            }
        }
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.markWatchList(movieId: movie.id, watchlist: !isWatchlist, completion: handleWatchlistResponse(success:error:))
    }
    
    func handleWatchlistResponse(success: Bool, error: Error?)
    {
        if success {
            if isWatchlist {
                // set the watchlist in the movie model to...every movie that is already in the watch list except for the one that we deleted
                MovieModel.watchlist = MovieModel.watchlist.filter()
                    {$0 != self.movie}
            } else {
                // if it is not in the watch list already, that means it was successfully added, so we can append it to the watch list in the movie model
                
                MovieModel.watchlist.append(movie)
            }
            
            // update the UI
            toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {

        TMDBClient.markFavorite(movieId: movie.id, favorite: !isFavorite, completion: handleFavoritelistResponse(success:error:))
      
    }
    
    func handleFavoritelistResponse(success: Bool, error: Error?)
    {
        // check if request was succesfl
        if success {
            if isFavorite {
                // if movie was already on the favorites list, filter it out
                MovieModel.favorites = MovieModel.favorites.filter()
                    {$0 != self.movie}
            } else {
                // if wasn't already on the favorites list, just append it
                MovieModel.favorites.append(movie)
            }
            
            toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        }
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    
}
