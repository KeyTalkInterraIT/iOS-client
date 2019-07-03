//
//  Providers.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.
//

import Foundation


struct UserModel: Decodable {
    let ConfigVersion: String
    let LatestProvider: String
    let LatestService: String
    var Providers: [Provider]
    
}

struct Provider: Decodable {
    let Name: String          
    let ContentVersion: Double
    let Server: String
    let LogLevel: String
    let CAs: [String]
    var Services: [Service]
    var imageLogo: Data? = nil
}

struct Service: Decodable {
    let Name: String
    let CertFormat: String?
    let CertChain: Bool?
    let Uri: String?
    let CertValidPercent: Int?
    let CertValidity: String?
    var Users: [String]?
}

struct RCCD {
    var imageData: Data
    var users: [UserModel]
}
