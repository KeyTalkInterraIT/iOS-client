//
//  AppDelegate.swift
//  KeyTalk
//
//  Created by Paurush on 5/15/18.

import UIKit
import CoreData
import Zip
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        Zip.addCustomFileExtension("rccd")
        
        //Retreiving last saved locale info
        Utilities.getLocalCode()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        //This is provide a url at which the rccd file is been stored. which is then used to unzip the rccd file and extracts the contents of it.
        Utilities.unzipRCCDFile(url: url) {[weak self] (success) in
            //creates an object of the rootViewController
            let vc = self?.window?.rootViewController as? ViewController
            if success {
                //if successful in unzipping the rccd file.
                DispatchQueue.main.async {
                    if let tempVC = vc {
                        if  tempVC.isKind(of: ViewController.self) {
                            //Refresh the contents of the RootVc or ServicesView with the contents of the downloaded rccd file.
                            tempVC.refreshData()
                        }
                    }
                }
            } else {
                //if the RCCD file downloaded is invalid or unable to unzip
                Utilities.showAlert(message: "invalid_rccd_file".localized(KTLocalLang), owner: vc!)
            }
        }
        
        return true
    }

    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "container_name".localized(KTLocalLang))
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("\("Unresolved_error".localized(KTLocalLang)) \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    /**
     This method is used to save the context of the core data.
     */
    func saveContext () {
        let lockQueue = DispatchQueue(label: "Locking_Queue".localized(KTLocalLang))
        lockQueue.sync() {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                //if there is any change in the context, then only the context will be saved.
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    //fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    print(nserror.description)
                }
            }
        }
        
    }
}

