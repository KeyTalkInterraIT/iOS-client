//
//  RCCDLogic.swift
//  APIConnect
//
//  Created by Paurush Gupta on 01/05/18.
//

import Foundation

var STATIC_HEIGHT = 0

struct RCCDLogic {
    
    
    var servicesArr: [UserModel]
    
    /**
     This is used to calculate the height to display.
     */
    func calculateHeight(aArr: [UserModel]) -> Int {
        var calculatedValue = 0
        
        if (aArr.count > 0) {
            //setting height of each element to 30.
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
    
    /**
     This method is used to search the values in the database, and if found will return all the values of the corresponding to that service.
     - Parameter textToSearch: the value needs to be searched in the database.
     - Returns : An array of type UserModel, corresponding to that value.
     */
    func searchArrAccToWriteValue(textToSearch: String?) -> [UserModel]? {
        guard let serviceValue = textToSearch ,serviceValue.count > 0 else {
            return nil
        }
        
        var filteredArr = [UserModel]()
        
        //iterating through the services array.
        for userModel in servicesArr {
            var userTempModel = userModel
            
            //an array of services.
            var filteredServices = [Service]()
            for services in userModel.Providers[0].Services {
                //if an element is present in the array.
                if services.Name.lowercased().contains(serviceValue.lowercased()) {
                    //add service in the filtered services array.
                    filteredServices.append(services)
                }
            }
            //if there are any matching services , them the whole model is appended into the array
            if filteredServices.count > 0 {
                userTempModel.Providers[0].Services = filteredServices
                filteredArr.append(userTempModel)
            }
        }
        
        return filteredArr
    }
}
