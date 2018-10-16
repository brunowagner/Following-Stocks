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

class DetailViewController2: UIViewController {
    
    var paper : Paper!
    //var paperStruct : PaperStruct!
    var quote : Quote!
    
    //MARK: Outlets
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTypeExchangeExchangeDisp: UILabel!
    @IBOutlet weak var labelSymbol: UILabel!
    @IBOutlet weak var labelprice: UILabel!
    @IBOutlet weak var labelchange: UILabel!
    @IBOutlet weak var labelchangePercent: UILabel!
    @IBOutlet weak var labelPreviousClose: UILabel!
    @IBOutlet weak var labelOpen: UILabel!
    @IBOutlet weak var labelHigh: UILabel!
    @IBOutlet weak var labelLow: UILabel!
    @IBOutlet weak var labelVolume: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var labelAveragePrice: UILabel!
    @IBOutlet weak var labelLatestTradingDay: UILabel!
    
    @IBOutlet weak var followButton: UIBarButtonItem!
    @IBOutlet weak var portfolioButton: UIBarButtonItem!

    @IBOutlet weak var viewSymbol: UIView!
    @IBOutlet weak var viewPrice: UIView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var stackViewPortfolio: UIStackView!
    
    
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
        
        DispatchQueue.main.async {
            self.configureUI()
        }


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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.configureUI()
        }
    }

    func fillUI(){
        self.labelName.text = paper.name
        self.labelSymbol.text = paper.symbol
        self.labelTypeExchangeExchangeDisp.text = "\(paper.type ?? "") - \(paper.exchange ?? "") - \(paper.exchDisp ?? "")"
        
        if paper.isPortfolio{
            self.labelQuantity.text = "\(paper.quantity)"
            self.labelAveragePrice.text = "\(paper.averageCost)"
            stackViewPortfolio.isHidden = false
        } else {
            stackViewPortfolio.isHidden = true
        }
        
        if paper.isFollowed {
            followButton.image = UIImage(named: "baseline_my_location_black_24pt")
        } else {
            followButton.image = UIImage(named: "baseline_location_disabled_black_24pt")
        }
    }
    
    func requestQuote(symbol : String) {
        AlphaVantageClient.requestQuote(symbol: symbol) { (globalQuote, error) in
            guard error == nil else {
                fatalError("Erro ao aobter cotação: \(String(describing: error?.localizedDescription))")
            }
            guard globalQuote != nil else{
                print("Quote = nil. Provavelmente não retornou informação na consulta do símbolo")
                //TODO: Codificar quota não encontrada ou veio vazia
                return
            }
            
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
        
        let add = UIAlertAction(title: "Purchase (add)", style: .default) { (alertAction) in
            self.addToPortfolio()
        }
        
        let remove = UIAlertAction(title: "Sale (remove)", style: .default) { (alertAcion) in
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
        self.labelprice.text =  String(format: "%.02f", globalQuote.price ) //"\(globalQuote.price)"
        self.labelchange.text =  "\(globalQuote.change)"
        self.labelchangePercent.text =  "(\(globalQuote.changePercent))"
        self.labelHigh.text = String(format: "%.02f", globalQuote.high ) //"\(globalQuote.high)"
        self.labelLatestTradingDay.text =  "\(globalQuote.latestTradingDay)"
        self.labelLow.text = String(format: "%.02f", globalQuote.low ) //"\(globalQuote.low)"
        self.labelOpen.text = String(format: "%.02f", globalQuote.open ) //"\(globalQuote.open)"
        self.labelPreviousClose.text = String(format: "%.02f", globalQuote.previousClose ) //"\(globalQuote.previousClose)"
        //self.symbolLabel.text = "\(globalQuote.symbol)"
        self.labelVolume.text = "\(globalQuote.volume)"
        if paper.isFollowed {
            followButton.image = UIImage(named: "baseline_my_location_black_24pt")
        } else {
            followButton.image = UIImage(named: "baseline_location_disabled_black_24pt")
        }
    }
}

//MARK: UIConfig
extension DetailViewController2 {
    func configureUI(){
        viewSymbol.layer.borderWidth = 1
        viewSymbol.layer.borderColor = UIColor.lightGray.cgColor
        
        viewPrice.layer.borderWidth = 1
        viewPrice.layer.borderColor = UIColor.lightGray.cgColor
        
        viewHeader.layer.borderWidth = 1
        viewHeader.layer.borderColor = UIColor.lightGray.cgColor
        }
}
