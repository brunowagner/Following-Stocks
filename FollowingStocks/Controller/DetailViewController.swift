//
//  DetailViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 24/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

/*
 Lógica:
 
 > ao iniciar:
 -      buscar na rede a cotação do papel recebido via modo de injeção
 -      carregar as view com os dados obtidos da rede.
 
 > ao clicar no botão "Add":
 -      Ir para uma view(modal) com formulario de adição
 -      No formulário:
 -          O usuário poderá cancelar a adição ou;
 -          O usuário irá preencher dados como quantidade, preço e data de compra.
 -          Ao clicar em adicionar os dados seráo persistidos no coredata e o formulário será dispensado.
 */

import UIKit

class DetailViewController: UIViewController {
    
    var paper : Paper!
    //var paperStruct : PaperStruct!
    var quote : Quote!
    
    //MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var lastestTradingDayLabel: UILabel!
    @IBOutlet weak var previousCloseLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changePercentLabel: UILabel!
    @IBOutlet weak var portfolioButton: UIBarButtonItem!
    @IBOutlet weak var followButton: UIBarButtonItem!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var averagePrice: UILabel!
    
    //MARK: Life`s Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        
        //pela nova arquitetura, paper nunca é nil
        if paper.quote != nil{
            print("DETAIL - criando quote...")
            quote = paper.quote
            print("DETAIL - quote criado!")
        } else {
            quote = Quote(context: DataController.sharedInstance().viewContext)
        }
        
        fillUI()

        requestQuote(symbol: paper.symbol!)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(type(of: self)) - viewWillAppear")
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(type(of: self)) - viewWillDisappear")
        self.tabBarController?.tabBar.isHidden = false
        
        //para limpar a memória (se paper não for salvo, deletar da memória)
        if !paper.isFollowed && !paper.isPortfolio{
            DataController.sharedInstance().viewContext.delete(paper)
        }
        //if paper was deleted in any viewController
        if paper.isDeleted {
            try? DataController.sharedInstance().viewContext.save()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(type(of: self)) - viewDidDisappear")

    }
    
    func fillUI(){
        self.nameLabel.text = paper.name
        self.symbolLabel.text = paper.symbol
        self.quantity.text = "\(paper.quantity)"
        self.averagePrice.text = "\(paper.averageCost)"
        if paper.isFollowed {
            followButton.image = UIImage(named: "baseline_my_location_black_24pt")
        } else {
            followButton.image = UIImage(named: "baseline_location_disabled_black_24pt")
        }
    }
    
    func requestQuote(symbol : String) {
        AlphaVantageClient.requestQuote(symbol: symbol) { (success, globalQuote, error) in
            
            if !success {
                guard globalQuote != nil else{
                    Alerts.message(view: self, title: "Alert!", message: "This paper have no quote!")
                    return
                }
                
                guard error != nil else {
                    let message = Errors.getDefaultDescription(errorCode:  Errors.ErrorCode(rawValue: (error?.code)!)!)
                    
                    Alerts.message(view: self, title: "Alert!", message: message)
                    return
                }
            }
            
//            guard error == nil else {
//                fatalError("Erro ao aobter cotação: \(String(describing: error?.localizedDescription))")
//            }
//            guard globalQuote != nil else{
//                print("Quote = nil. Provavelmente não retornou informação na consulta do símbolo")
//                //TODO: Codificar quota não encontrada ou veio vazia
//                return
//            }
            
            print("DETAIL - setando quoter...")
            self.quote.change = (globalQuote?.change)!
            self.quote.changePercent = globalQuote?.changePercent
            self.quote.high = (globalQuote?.high)!
            self.quote.latest = Utilities.Convert.stringToDate((globalQuote?.latestTradingDay)!, dateFormat: "yyyy-mm-dd")
            self.quote.low = (globalQuote?.low)!
            self.quote.open = (globalQuote?.open)!
            self.quote.previousClose = (globalQuote?.previousClose)!
            self.quote.price = (globalQuote?.price)!
            self.quote.volume = (globalQuote?.volume)!

            self.quote.paper = self.paper
            self.paper.quoteDate = Date()
            print("DETAIL - quoter setado!")
            
            //self.quote = Quote(context: DataController.sharedInstance().viewContext)
            DispatchQueue.main.async {
                self.reloadUIData(globalQuote: globalQuote!)
            }
        }
    }
    
    
    //MARK: Actions
    @IBAction func portfolioAction(_ sender: Any) {
        print("presentPortfolioTradeAlert - inicio")
        presentPortfolioTradeAlert()
        print("presentPortfolioTradeAlert - fim")
    }
    
    @IBAction func followButton(_ sender: Any) {
        paper.isFollowed = !paper.isFollowed
        if paper.isFollowed {
            followButton.image = UIImage(named: "baseline_my_location_black_24pt")
            try? DataController.sharedInstance().viewContext.save()
        } else {
            followButton.image = UIImage(named: "baseline_location_disabled_black_24pt")
            try? DataController.sharedInstance().viewContext.save()
        }
    }
    
    
    func presentPortfolioTradeAlert() {
        let alert = UIAlertController(title: "Portfolio Trade", message: "What trade do you might?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let add = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            self.addToPortfolio()
        }
        
        let remove = UIAlertAction(title: "Remove", style: .default) { (alertAcion) in
            self.removeFromPortFolio()
        }
        
        alert.addAction(cancel)
        alert.addAction(remove)
        alert.addAction(add)
        
        remove.isEnabled = paper.isPortfolio
        
        present(alert, animated: true, completion: nil)
    }
    
    func addToPortfolio() {
        let m = storyboard?.instantiateViewController(withIdentifier: "MovingPortfolioViewController") as! MovingPortfolioViewController
        
        print("DETAIL - injetando paper...")
        m.paper = paper
        m.operation = Trade.OperationType.purchase
        print("DETAIL - paper injetado!")
        
        present(m, animated: true, completion: nil)
    }
    
    func removeFromPortFolio() {
        print("removeFromPortFolio - inicio")
        
        let m = storyboard?.instantiateViewController(withIdentifier: "MovingPortfolioViewController") as! MovingPortfolioViewController
        
        print("DETAIL - injetando paper...")
        m.paper = paper
        m.operation = Trade.OperationType.sale
        print("DETAIL - paper injetado!")
        
        present(m, animated: true, completion: nil)
        
        print("removeFromPortFolio - fim")
    }
    
    func reloadUIData(globalQuote: GlobalQuote){
        self.priceLabel.text =  "\(globalQuote.price)"
        self.changeLabel.text =  "\(globalQuote.change)"
        self.changePercentLabel.text =  "\(globalQuote.changePercent)"
        self.highLabel.text = "\(globalQuote.high)"
        self.lastestTradingDayLabel.text =  "\(globalQuote.latestTradingDay)"
        self.lowLabel.text = "\(globalQuote.low)"
        self.openLabel.text = "\(globalQuote.open)"
        self.previousCloseLabel.text = "\(globalQuote.previousClose)"
        self.symbolLabel.text = "\(globalQuote.symbol)"
        self.volumeLabel.text = "\(globalQuote.volume)"
        if paper.isFollowed {
            followButton.image = UIImage(named: "baseline_my_location_black_24pt")
        } else {
            followButton.image = UIImage(named: "baseline_location_disabled_black_24pt")
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
