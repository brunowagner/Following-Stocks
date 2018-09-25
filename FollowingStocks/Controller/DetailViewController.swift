//
//  DetailViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 24/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var paper : Paper!
    var paperStruct : paperStruct!
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillUI()
        
        requestQuote(symbol: paperStruct.symbol)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillUI(){
        self.nameLabel.text = paperStruct.companyName
        self.symbolLabel.text = paperStruct.symbol
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
            
            //self.quote = Quote(context: DataController.sharedInstance().viewContext)
            DispatchQueue.main.async {
                
                self.reloadUIData(globalQuote: globalQuote!)
            }
            
        }
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
