//
//  SearchViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 16/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import UIKit


struct paperStruct {
    let symbol: String //: "PBR",
    let companyName: String  //: "Petróleo Brasileiro S.A. - Petrobras",
    let exch: String  //: "NYQ",
    let type: String  //: "S",
    let exchDisp: String  //: "NYSE",
    let typeDisp: String  //: "Equity"
    
    init(dicPaper: [String: AnyObject]) {
        self.symbol = dicPaper["symbol"] as! String
        self.companyName = dicPaper["name"] as! String
        self.exch = dicPaper["exch"] as! String
        self.type = dicPaper["type"] as! String
        self.exchDisp = dicPaper["exchDisp"] as! String
        self.typeDisp = dicPaper["typeDisp"] as! String
    }
    
    static func parseToPapelArray(from resultSet: [String : AnyObject]) -> [paperStruct]{
        guard let rs = resultSet["ResultSet"] as? [String : AnyObject] else {
            fatalError("Não foi encontrado 'ResultSet nos dados baixados.'")
        }
        
        guard let results = rs["Result"] as? [[String :AnyObject]] else {
            fatalError("Não foi encontrado 'Result nos dados baixados.'")
        }

        var papelArray : [paperStruct] = []
        
        for data in results {
            let papel = paperStruct(dicPaper: data)
            papelArray.append(papel)
        }
        return papelArray
    }
}

class SearchViewController : UITableViewController {
    

    var papelArray : [paperStruct]!
    var filteredPapelArray : [paperStruct]!
    
    var papelDetails : paperStruct!

    var searchController : UISearchController!
    var operation : String = "default"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if papelArray == nil { papelArray = [] }
        filteredPapelArray = papelArray
		tableView.dataSource = self
		tableView.delegate = self
		configureSearchController()
        definesPresentationContext = true
        print("operation =  \(operation)")
    }
    
	func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
	}
	
    func requestDataFromServer(query : String){
        
        let parameters = [
            "query" : query,
            "region" : "1",
            "lang" : "en"
            ] as [String: AnyObject]
        
        let _ = HTTPTools.taskForGETMethod("", parameters: parameters, apiRequirements: AutocompleteApiRequirements()) { (data, error) in
            guard error == nil else{
                fatalError("vouve um erro ao baixar os dados : " + (error?.localizedDescription)!)
            }
            print(data!)
            
            //self.filteredPapelArray = paperStruct.parseToPapelArray(from: data as! [String : AnyObject])
            
            DispatchQueue.main.async {
                self.filteredPapelArray = paperStruct.parseToPapelArray(from: data as! [String : AnyObject])
                self.tableView.reloadData()
            }
        }
        
        
        
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        //let detailsVC = segue.destinationViewController as! DetailsViewController
        //detailsVC.userDetails = userDetails
    }
    

}

//MARK: UITableViewDataSource
extension SearchViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPapelArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchTableViewCell
        
        let paper : paperStruct = filteredPapelArray[indexPath.row]
        print(paper.symbol)

        cell.symbolLable.text = paper.symbol
        cell.nameLable.text = paper.companyName
        cell.exchangeLable.text = paper.exch + " - " + paper.exchDisp

        return cell
    }
}

extension SearchViewController : UISearchResultsUpdating {
    
	func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText.isEmpty {
                filteredPapelArray = papelArray
            } else {
                requestDataFromServer(query : searchText)
            }
            tableView.reloadData()
        }
	}
} 

//MARK: UITableViewDelegate
extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    //adicionado para add
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == tableView.indexPathForSelectedRow {
            //TODO: desmarcar celula
        }
        
        //TODO: pegar symbol e pesquizar Cotação
        let paper = filteredPapelArray[indexPath.row]
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailVC.paperStruct = paper
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        
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
