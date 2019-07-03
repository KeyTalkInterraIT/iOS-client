//
//  KeytalkAuthentication.swift
//  Created by Anshuman Singh on 18/06/18.

import Foundation
import UIKit
import LocalAuthentication

//Delegate for the authentication callback
protocol KTHardwareAuthenticationDelegate : class {
    
    /**
     This function provides the result of the biometric authentication.
     
     - Parameter isSuccess : wheather the authentication is successfull or not.
     - Parameter authError : provides the authentication error in case of unsucessfull authentication.
    */
    func getValidationResult (isSuccess: Bool , authError:Error?)
}

public class KTHardwareAuthentication  {
    
    //Context object to evaluate the policy.
    let authContext:LAContext = LAContext()
   
    //This reason is shown to the user inorder to notify them to validate them.
    let reason = "Biometric_Reason".localized(KTLocalLang)
    var error:NSError?
   
    //Delegate object
    var ktHardwareAuthenticationDelegate : KTHardwareAuthenticationDelegate
    
    init(obj : KTHardwareAuthenticationDelegate) {
        //set the delegate with the parent class inorder to send the callback.
        self.ktHardwareAuthenticationDelegate = obj
    }
    
    /**
     This function verify the user biometric authentication through TouchID/FaceID or passcode,by validating the user inputs.
     */
    public func verifyWithTouchIdFaceIDorPasscode() {
        
        //Is Touch ID hardware available & configured?
        if(authContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error:&error))
        {
            //Perform Touch ID or Face ID auth and if authentication fails then the user can authenticate through passcode .
            authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: {
                (wasSuccessful:Bool, error:Error?) in
                //sending callback to the parent class, when the authentication is successfull.
                self.ktHardwareAuthenticationDelegate.getValidationResult(isSuccess: wasSuccessful, authError: error)
            })
        }
        else
        {
            //Missing the hardware or Touch ID/FaceID/Passcode isn't configured
            self.ktHardwareAuthenticationDelegate.getValidationResult(isSuccess: false, authError: error)
        }
    }
}

