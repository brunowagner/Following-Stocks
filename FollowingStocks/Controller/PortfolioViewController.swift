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
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var autoRefreshButton: UIBarButtonItem!

    //MARK: Life's cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        setupPaperFetchedResultsController()
        //PortfolioViewController.countPapers = fetchedResultsController.sections[0].numberof
        tableView.dataSource = self
        tableView.delegate = self
        autoRequestQuote(interval: 60, requestsPerInterval: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(type(of: self)) - viewWillAppear")
        setupPaperFetchedResultsController()
        tableView.reloadData()
        //if let indexPath = tableView.indexPathForSelectedRow {
        //    tableView.deselectRow(at: indexPath, animated: false)
        //    tableView.reloadRows(at: [indexPath], with: .fade)
        //}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(type(of: self)) - viewDidDisappear")
        fetchedResultsController = nil
    }

    //MARK: Fetcheds
    
    fileprivate func setupPaperFetchedResultsController() {
        print("Iniciando Fetched...")
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        
        let predicate = NSPredicate(format: "isPortfolio == %@", NSNumber(value: true))
        
        let sortDescriptor = NSSortDescriptor(key: "symbol", ascending: true)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //------------ apenas para testar o fetchRequst puro
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            let papers : [Paper] = result

            //for p in papers{
            //    print(p.symbol)
            //}
            
            print(papers.count)
            //print(papers)
        }
        //----------
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)//"paperFRC")
        
        fetchedResultsController.delegate = self

        do{
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Can not to do fetchedResultsController.performFetch!")
        }
    }
    
    static func getPapersCount() -> Int {
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        let predicate = NSPredicate(format: "isPortfolio == %@", NSNumber(value: true))
        fetchRequest.predicate = predicate
        
        if let result = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
            return result.count
        } else {
            return 0
        }
    }
    
    //MARK: Actions
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        if PortfolioViewController.getPapersCount() >= 5 {
            Alerts.message(view: self, title: "Alert!", message: "Limit of papers in portfolio just was reached!")
            return
        }
        let m = self.storyboard?.instantiateViewController(withIdentifier: "MovingPortfolioViewController") as! MovingPortfolioViewController
        m.operation = Trade.OperationType.purchase
        
        present(m, animated: true, completion: nil)
    }
    
    
    //TODO: Remove this action
    func autoRequestQuote(interval:TimeInterval = 60, requestsPerInterval : Int = 1) {
        
        guard requestsPerInterval > 0 else { return }
        
        let fetchRequest : NSFetchRequest<Paper> = Paper.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "quoteDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //let predicate = NSPredicate(format: "isPortfolio == %@", NSNumber(value: true))
        //fetchRequest.predicate = predicate
        
        guard let result = try? DataController.sharedInstance().backgroundContext.fetch(fetchRequest), result.count > 0 else {
            return
        }
        
        for index in 0...(requestsPerInterval-1) {
            let paper = result[index]
            
            AlphaVantageClient.requestQuote(symbol: paper.symbol!) { (success, globalQuote, error) in
                guard success else {
                    let message = Errors.getDefaultDescription(errorCode:  Errors.ErrorCode(rawValue: (error?.code)!)!)
                    print(message)
                    return
                }
                
                guard globalQuote != nil else{
                    print ("This paper have no quote!")
                    return
                }
                
                print("PORTFOLIO - setando autoRequestQuoter...")
                paper.quote?.change = (globalQuote?.change)!
                paper.quote?.changePercent = globalQuote?.changePercent
                paper.quote?.high = (globalQuote?.high)!
                paper.quote?.latest = Utilities.Convert.stringToDate((globalQuote?.latestTradingDay)!, dateFormat: "yyyy-MM-dd")
                paper.quote?.low = (globalQuote?.low)!
                paper.quote?.open = (globalQuote?.open)!
                paper.quote?.previousClose = (globalQuote?.previousClose)!
                paper.quote?.price = (globalQuote?.price)!
                paper.quote?.volume = (globalQuote?.volume)!
                paper.quoteDate = Date()
                print("\(paper.symbol) - \(paper.quoteDate)")
                print("Portifolio - autoRequestQuoter setado!")
                
                DispatchQueue.main.async {
                    try? DataController.sharedInstance().backgroundContext.save()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoRequestQuote(interval: interval, requestsPerInterval: requestsPerInterval)
        }
    
    }
    
    //TODO: Remove this function
    func showLoadingIndicator (_ show : Bool ){
        performUIUpdatesOnMain {
            if show{
                LoadingOverlay.shared.showOverlay(view: self.view)
            }else{
                LoadingOverlay.shared.hideOverlayView()
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioCell", for: indexPath) as! PortfolioCell
        
        let paper = fetchedResultsController.object(at: indexPath)
        
//        cell.symbol.text = paper.symbol
//        cell.exchange.text = paper.exchange
//        cell.price.text = "\(paper.quote?.price ?? 0)"
//        //cell.change.text = "\(paper.quote?.change ?? 0)"
//        cell.setChange(value: paper.quote?.change ?? 0, percent: paper.quote?.changePercent ?? "0%")
//
        cell.setFieldsBy(paper: paper)
        
        return cell
    }
}

    //MARK: UITableViewDelegate
extension PortfolioViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        //TODO: pegar symbol e pesquizar Cotação
        //let paper = fetchedResultsController.object(at: indexPath)
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController2") as! DetailViewController2
        detailVC.paper = fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        //performSegue(withIdentifier: "SearchToDetail", sender: paper)
        
        //        AlphaVantageClient.sharedInstance.requestQuote(symbol: paper.symbol) { (globalQuote, error) in
        //            guard error == nil else {
        //                fatalError("Erro ao aobter cotação: \(error?.localizedDescription)")
        //            }
        //
        //            let quote = Quote(context: DataController.sharedInstance().viewContext)
        //
        //
        //        }

        //TODO: instanciar Detail
        //TODO: injetar paper e quote em Detail
        //TODO: Navejar até detail.

        //        if tableView == resultsController.tableView{
        //            userDetails = foundUsers[indexPath.row]
        //            self.performSegue(withIdentifier: "PushDetailsVC", sender: self)
        //        }
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
            print("FRC type = insert")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            print("FRC type = delete")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            print("FRC type = update")
            tableView.reloadData()
            break
        case .move:
            print("FRC type = move")
                //move isn't applied in this app
            break
        }
    }
}
