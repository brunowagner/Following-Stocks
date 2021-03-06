//
//  DataController.swift
//  VirtualTourist
//
//  Created by Bruno W on 23/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    
    //MARK: Properties
    var persistentContainer : NSPersistentContainer
    var viewContext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    var backgroundContext: NSManagedObjectContext!
    
    //MARK: - Methods
    private init(modelName : String){
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()->Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDiscription, error) in
            //se houver erro, para o app e lança uma "fatalErro"
            guard error == nil else{
                fatalError((error?.localizedDescription)!)
            }
            
            // função criada para configurar os contextos da fila principal e da fila privada(background)
            self.configureContexts()
            
            print ("Data Stack Loaded")
            completion?()
        }
    }
    
    private func configureContexts(){
        
        //instancia um contexto associado com uma fila privada
        backgroundContext = persistentContainer.newBackgroundContext()
        
        //determina que os contextos pares realizem a fusão de mudanças automaticamente
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //define as políticas de fusão para que o app não trave em caso de conflito
        // mergeByPropertyObjectTrump -> prefere os valores das propriedades do objeto em caso de conflito.
        // mergeByPropertyStoreTrump -> prefere os valores das propriedades do persistentStore em caso de conflito.
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    // função para salvamento em intervalos
    func autoSaveViewContext(interval : TimeInterval = 30){
        print("autosaving...")
        guard interval > 0 else{
            print("Cannot set negative autosave interval")
            return
        }
        // sá salva se houver mudanças no contexto.
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }


    // MARK: - Shared Instance
    class func  sharedInstance() -> DataController{
        struct Singleton{
            static let sharedInstance = DataController(modelName: "FollowingStocks")
        }
        return Singleton.sharedInstance
    }
}
