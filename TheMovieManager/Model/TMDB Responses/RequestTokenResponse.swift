//
//  RequestTokenResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

// 3. Create a new struct of the same name

struct RequestTokenResponse: Codable
{
    let success: Bool
    let expiresAt: String
    let requestToken: String
    
    enum CodingKeys: String, CodingKey
    {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}

// Now go back into TMDB Client to make the request
