//
//  PortfolioViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 21/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

/*
    Lógica:
 
 > ao iniciar:
 -      Procurar dados de papeis e cotações persistidos no core data
 -      carregar a tabela (tableView)
 
 > ao clicar no botão "Add":
 -      Ir para searchView informado que é uma operação de adição
 -      Na searchView:
 -          ao encontrar o clicar no papel:
 -              exibir janela de input com os campos já preenchidos aguardando apenas a confirmação do usuário
 -              se o usuário clicar em add:
 -                  se papel já existe, realizar adição da quantidade e calcular o preco médio
 -                  se o papel não existe, adicionar os dados do papel além de quantidades e preço
 -              se o usuário clicar em cancelar:
 -                  voltar para a view do portifolio.
 */

import UIKit
import CoreData

class PortfolioViewController: UIViewController {
    
    var fetchedResultsController : NSFetchedResultsController<Paper>!
    
    @IBOutlet weak var tableView: UITableView!


    //MARK: Life's cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupPaperFetchedResultsController()
        
        //tableView.dataSource = self

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Fetcheds
    
    fileprivate func setupPaperFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        
        let predicate = NSPredicate(format: "isPortfolio = %@", "true")
        
        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: true)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: "paperFRC")
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Can not to do fetchedResultsController.performFetch!")
        }
    }
}


    // MARK: UITableViewDataSource
extension PortfolioViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioCell") as! PortfolioCell
        
        let paper = fetchedResultsController.object(at: indexPath)
        
        cell.symbol.text = paper.symbol
        cell.exchange.text = paper.exchange
        cell.price.text = "\(paper.quote?.price ?? 0)"
        cell.change.text = "\(paper.quote?.change ?? 0)"
        
        return cell
    }
}



    // MARK: - NSFetchedResultsControllerDelegate
extension PortfolioViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [indexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadData()
            break
        case .move:
                //move isn't applied in this app
            break
        }
    }
}
