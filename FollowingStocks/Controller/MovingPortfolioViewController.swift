//
//  MovingPortfolioViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 25/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class MovingPortfolioViewController: UIViewController {

    //MARK: Properties
    var paper: Paper!
    var quote: Quote!
    var trade: Trade!
    var operation: Trade.OperationType!
    let moneyDelegate = MoneyTextFieldDelegate(prefix: "")
    
    var keyboardHeight: CGFloat!
    // Constraints
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    //MARK: Outlets
    @IBOutlet weak var paperTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var navigatioBar: UINavigationBar!
    
    var activeField: UITextField!



    
    //MARK: Life`s cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        
        quantityTextField.delegate = self
        priceTextField.delegate = moneyDelegate
        dateTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        fillUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //subscriberToKeyboardNotifications()
    }


    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(type(of: self)) - viewWillDisappear")
        //unSubscriberToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(type(of: self)) - viewDidDisappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    func fillUI(){
        paperTextField.text = paper?.symbol
        quantityTextField.text = "0"
        priceTextField.text = String(format: "%.02f", paper?.quote?.price ?? 0)
        dateTextField.text = dateFormatter.string(from: Date())
        self.tradeButton.setTitle(operation.rawValue, for: .normal)
    }
    
    @IBAction func searchAction(_ sender: Any) {
         print("\(type(of: self)) - performSegue")
        performSegue(withIdentifier: "MovingYourPortifolioToSearch", sender: nil)
    }
    
    @IBAction func stepperValueChange(_ sender: UIStepper) {
        quantityTextField.text = Int(sender.value).description
    }
    
    
    @IBAction func unwindToMovingPortfolioViewController(_ sender: UIStoryboardSegue) {
        print("\(type(of: self)) - unwindToMovingPortfolioViewController")
        let vc = sender.source as! SearchViewController
        paper = vc.paper
        self.paperTextField.text = paper.symbol
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        print("\(type(of: self)) - cancelAction")
        if paper != nil, !paper.isPortfolio && !paper.isFollowed {
            DataController.sharedInstance().viewContext.delete(paper)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DateAction(_ sender: Any) {
        getDate()
    }
    
    @IBAction func tradeAction (_ sender: UIButton){
        
        
        guard isPaperSelected() else {
            Alerts.message(view: self, title: "Paper was not selected!", message: "\nPlease, inform Paper.")
            return
        }
        
        guard isQuantityValid() else {
            Alerts.message(view: self, title: "Invalid quantity!", message: "\nPlease, inform Quantity.")
            return
        }
        
        guard isPriceValid() else {
            Alerts.message(view: self, title: "Invalid price!", message: "\nPlease, inform Price.")
            return
        }
        
        let quantidade = Int16((quantityTextField.text! as NSString).intValue)
        let price = (self.priceTextField.text! as NSString).doubleValue
        
        
        switch operation! {
        case .sale:
            if quantidade > paper.quantity {
                Alerts.message(view: self, title: "The quantity exceeded the limit!", message: "This paper have only \(paper.quantity). Choose this quantity or less!")
                return
            } else if quantidade == paper.quantity {
                DataController.sharedInstance().viewContext.delete(paper)
                dismiss(animated: true, completion: nil)
                return
            } else {
                paper.quantity -= quantidade
            }
            break
  
        case .purchase:
            paper.averageCost = averageCost(quantityA: paper.quantity, costA: paper.averageCost, quantityB: quantidade, costB: price)
            paper.quantity += quantidade
            paper.isPortfolio = true
        }

        trade = Trade(context: DataController.sharedInstance().viewContext)
        trade.date = dateFormatter.date(from: self.dateTextField.text!)
        trade.operation = operation.rawValue
        trade.price = price
        trade.quantity = quantidade

        trade.paper = paper

        print(trade)

        print(paper)

        do{
            try DataController.sharedInstance().viewContext.save()
            dismiss(animated: true, completion: nil)
        } catch {
            fatalError("Não foi possivel salva no core data")
        }
    }
    
    func isPaperSelected() -> Bool{
        return !self.paperTextField.text!.isEmpty
    }
    func isQuantityValid() -> Bool{
        return Int(self.quantityTextField.text!)! > 0
    }
    func isPriceValid() -> Bool{
        return Float(self.priceTextField.text!)! > 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\(type(of: self)) - prepareforSegue")
        if let searchVC = segue.destination as? SearchViewController{
            searchVC.isToFillField = true
        }
    }
    
    func averageCost(quantityA : Int16, costA: Double, quantityB: Int16, costB: Double) -> Double{
        let response = (( Double(quantityA) * costA) + (Double(quantityB) * costB)) / ( Double(quantityA) + Double(quantityB))
        return response
    }

}

extension MovingPortfolioViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    @objc func dismissKeyboard(){
        //activeField?.resignFirstResponder()
        view.endEditing(true)
        activeField = nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        if activeField == dateTextField{
            dismissKeyboard()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
//        activeField?.resignFirstResponder()
//        activeField = nil
        return true
    }
}

//MARK: Functions when KeyBoard Appears and Disappears
extension MovingPortfolioViewController {

    func subscriberToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unSubscriberToKeyboardNotifications(){
        //Notifications can be removeds one by one or all at once
        //Following sugestions, i changed to remove all at once.
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification : Notification){
        //view.frame.origin.y -= getKeyboardHeight(notification)
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardY = self.view.frame.size.height - keyboardSize.cgRectValue.height
        
        let editingTextFieldY : CGFloat! = self.activeField?.superview?.frame.origin.y
        
        if editingTextFieldY > keyboardY - 80 {
            view.frame.origin.y -= (editingTextFieldY - (keyboardY - 80))
        }
    }
    
    @objc func keyboardWillHide(){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification : Notification) -> CGFloat{
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

//MARK: Alert with datePicker
extension MovingPortfolioViewController{

    func getDate() {
        let message = "\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: "Select Date", message: message, preferredStyle: .alert)
        alert.isModalInPopover = true
        
     
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 260, height: 150))
        datePicker.datePickerMode = .date
        
        datePicker.maximumDate = Date()
        
        alert.view.addSubview(datePicker)
        datePicker.frame.origin.y += 40
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.dateTextField.text = self.dateFormatter.string(from: datePicker.date)
        })
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
