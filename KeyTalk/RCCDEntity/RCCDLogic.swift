//
//  RCCDLogic.swift
//  APIConnect
//
//  Created by Paurush Gupta on 01/05/18.
//  Copyright © 2018 Paurush Gupta. All rights reserved.
//

import Foundation

var STATIC_HEIGHT = 0

struct RCCDLogic {
    
    var servicesArr: [UserModel]
    
    func calculateHeight(aArr: [UserModel]) -> Int {
        var calculatedValue = 0
        
        if (aArr.count > 0) {
            let tempHeight = aArr.count * 30
            if tempHeight < calculatedValue {
                calculatedValue = tempHeight
            }
            else {
                calculatedValue = STATIC_HEIGHT
            }
        }
        
        return calculatedValue
    }
    
    func searchArrAccToWriteValue(textToSearch: String?) -> [UserModel]? {
        guard let serviceValue = textToSearch else {
            return nil
        }
        
        var filteredArr = [UserModel]()
        
        if serviceValue.count > 0 {
            for userModel in servicesArr {
                var userTempModel = userModel
                
                var filteredServices = [Service]()
                for services in userModel.Providers[0].Services {
                    if services.Name.lowercased().contains(serviceValue.lowercased()) {
                        filteredServices.append(services)
                    }
                }
                
                if filteredServices.count > 0 {
                    userTempModel.Providers[0].Services = filteredServices
                    filteredArr.append(userTempModel)
                }
            }
        }
        else {
            filteredArr = servicesArr
        }
        
        return filteredArr
    }
}
