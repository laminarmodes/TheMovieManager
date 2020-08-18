//
//  TMDBResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct TMDBResponse: Codable {
    
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

// Error step 2. Conform to Localized error. LocaliezdError means we can provide an error message that is more readable (even language specific)
extension TMDBResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}
