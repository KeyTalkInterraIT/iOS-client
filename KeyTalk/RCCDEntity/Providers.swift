//
//  Providers.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation


struct UserModel: Decodable {
    
    let ConfigVersion: String
    let LatestProvider: String
    let LatestService: String
    var Providers: [Provider]
    
//    var ConfigVersion =  ""
//    var LatestProvider = ""
//    var LatestService = ""
//    var Providers = [Provider]()
    
//    func encode(with aCoder: NSCoder) {
//        /*aCoder.encode(self.ConfigVersion, forKey: "ConfigVersion")
//        aCoder.encode(self.LatestProvider, forKey: "LatestProvider")
//        aCoder.encode(self.LatestService, forKey: "LatestService")
//        aCoder.encode(self.Providers, forKey: "Providers")*/
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//
//    }
    
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
    let CertFormat: String
    let CertChain: Bool
    let Uri: String
    //var KeyAgreement: String
    let CertValidPercent: Int
    //var ProxySettings = ""
    var Users: [String]
}

struct RCCD {
    var imageData: Data
    var users: [UserModel]
}
