//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

// Authentication Flow
// Creating the request token
// Validating the request token
// Creating the session ID
// Deleting the session (logging out)

class TMDBClient {
    
    static let apiKey = "6f82668ad87531cdd0a32eea129e65b6"
    
    //static let apiKay = ""
    
    struct Auth {
        // reference by structName.propertyName
        // not belong to any instance oft he TMDBClient class
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        // Endpoints
        case getWatchlist
        // 1. To make request, need the URL
        case getRequestToken
        // STEP 2: Need a new endpoint
        case login
        case createSessionId
        case webAuth
        case logOut
        case getFavorites
        case search(String)
        case markWatchlist
        case markFavorite
        case posterImage(String)
        
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                // 2. To build string value, handle this case
            // concatinate 3 components to build URL: Base, endpoings and API Key
            case .getRequestToken:
                return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
            // Now open up response.  Go to RequestTokenResponse.swift
            case .login:
                return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
            case .createSessionId:
                return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
            case .webAuth:
                return "https://www.themoviedb.org/authenticate/" + Auth.requestToken + "?redirect_to=themoviemanager:authenticate"
            // quary parameter is "redirect_to" and since it is the first one, need to start wtih a "?".  "authenticate" is the path
            case .logOut:
                return Endpoints.base + "/authentication/session" + Endpoints.apiKeyParam
            case .getFavorites:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .search(let query):
                return Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" // query is our search string.  Value will come from a search box in one of the ViewControllers.  Cannot access it here, but can use associated values to access the URL, regardless of the search string
            case .markWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .markFavorite:
                return Endpoints.base + "/account/\(Auth.accountId)/favorite" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .posterImage(let posterPath):
                return "https://image.tmdb.org/t/p/w500" + posterPath
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func downloadPosterImage(posterPath: String, completion: @escaping (Data?, Error?) -> Void)
    {
        
        let task = URLSession.shared.dataTask(with: Endpoints.posterImage(posterPath).url) {(data, response, error) in
            // both are optionals so can be nil, so don't need to check for nil here so just call in completion handler (also updating the UI on the main thread)
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
        
    }
    
    class func search(query: String, completion: @escaping ([Movie], Error?) -> Void) -> URLSessionTask
    {
        let task = taskForGETRequest(url: Endpoints.search(query).url, responseType: MovieResults.self){(response, error) in
            
            if let response = response{
                completion(response.results, nil)
            } else
            {
                completion([], error)
            }
        }
        return task
    }
    
    class func markWatchList(movieId: Int, watchlist: Bool, completion: @escaping (Bool, Error?) -> Void)
    {
        let body = MarkWatchList(mediaType: "movie", mediaId: movieId, watchlist: watchlist)
        
        taskForPOSTRequest(url: Endpoints.markWatchlist.url, responseType: TMDBResponse.self, body: body) {(response, error) in
            if let response = response {
                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
            } else
            {
                completion(false, nil)
            }
        }
    }
    
    class func markFavorite(movieId: Int, favorite: Bool, completion: @escaping (Bool, Error?) -> Void)
    {
        let body = MarkFavorite(mediaType: "movie", mediaId: movieId, favorite: favorite)
        
        taskForPOSTRequest(url: Endpoints.markFavorite.url, responseType: TMDBResponse.self, body: body) {(response, error) in
            if let response = response {
                completion(response.statusCode == 1 || response.statusCode == 12 || response.statusCode == 13, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    // 4.  make the request
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void)
    {
        // this is nearly identical to the other get request we use to make the watch list
        // update endpoint to "getRequestToken"
        // response type is "RequestTokenResponse"
        // pass in 'true' is parsing was successful, and false otherwise
        
        
        taskForGETRequest(url: Endpoints.getRequestToken.url, responseType: RequestTokenResponse.self) {(response, error) in
                if let response = response {
                    Auth.requestToken = response.requestToken
                    completion(true, nil) }
                else {
                    completion(false, error)
                }
            }
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    {
 
        // create instance of the LoginRequest struct for the request body
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)

        taskForPOSTRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: body){(response, error) in
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func createSessionId(completion: @escaping (Bool, Error?) -> Void)
    {
        taskForPOSTRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: PostSession(requestToken: Auth.requestToken)){(response, error) in
                   if let response = response {
                       Auth.sessionId = response.sessionId
                       completion(true, nil)
                   } else {
                       completion(false, nil)
                   }
               }
    }
    
    // Does not need to pass back any parameters (do not care about error)
    class func logout(completion: @escaping () -> Void)
    {
        var request = URLRequest(url: Endpoints.logOut.url)
        request.httpMethod = "DELETE"
        let body = LogoutRequest(sessionId: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("applicatoin/json", forHTTPHeaderField: "Content-type")
        
        let task = URLSession.shared.dataTask(with: request){(data, response, error) in
            Auth.requestToken = ""
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        
    
        taskForGETRequest(url: Endpoints.getWatchlist.url, responseType: MovieResults.self) {(response, error) in
                if let response = response {
                    // if the response is successful, the array of movies is passed into the completion handler
                    completion(response.results, nil) }
                else {
                    completion([], error)
                }
            }
    }
    
    class func getFavourites(completion: @escaping ([Movie], Error?) -> Void)
    {
        taskForGETRequest(url: Endpoints.getFavorites.url, responseType: MovieResults.self){(response, error) in
            if let response = response {
                completion(response.results, nil)
            }
            else {
                completion([],error)
            }
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask
    {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                // if JSON Parsing succeds
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
  
            } catch {
                
                do
                {
                    // Error step 1. parse the error response (TMDBResponse)
                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
                    
                    // Error step 3. set the error message to be the status message form the Movie database
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                }
                catch
                {
                    // if JSON Parsing fails
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void)
    {


        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                
                
                do {
                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                    completion(nil, error)
                }
                 
                    
                }
            }
        }
        task.resume()
    }
}

