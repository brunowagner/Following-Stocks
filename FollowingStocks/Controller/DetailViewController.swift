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
    var paperStruct : PaperStruct!
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
    
    //MARK: Life`s Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if paper == nil{
        print("DETAIL - criando paper...")
        paper = Paper(context: DataController.sharedInstance().viewContext)
        print("DETAIL - paper criado!")
            print("DETAIL - criando quote...")
        quote = Quote(context: DataController.sharedInstance().viewContext)
            print("DETAIL - quote criado!")
            
            print("DETAIL - setando paper...")
            paper.symbol = paperStruct.symbol
            paper.name = paperStruct.companyName
            paper.exchange = paperStruct.exch
            paper.exchDisp = paperStruct.exchDisp
            paper.type = paperStruct.type
            paper.typeDisp = paperStruct.typeDisp
            print("DETAIL - paper setado!")
            
        } else {
            print("DETAIL - criando quote...")
            quote = paper.quote
            print("DETAIL - quote criado!")
        }
        
        fillUI()

        requestQuote(symbol: paper.symbol!)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //DataController.sharedInstance().viewContext.delete(paper)
    }
    
    func fillUI(){
        self.nameLabel.text = paper.name
        self.symbolLabel.text = paper.symbol
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
    
    @IBAction func portfolioAction(_ sender: Any) {
        
        let m = storyboard?.instantiateViewController(withIdentifier: "MovingPortfolioViewController") as! MovingPortfolioViewController
        
        print("DETAIL - injetando paper...")
        m.paper = paper
        print("DETAIL - paper injetado!")
        
        present(m, animated: true, completion: nil)
    }
    
    func reloadUIData(globalQuote: AlphaVantageClient.GlobalQuote){
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
