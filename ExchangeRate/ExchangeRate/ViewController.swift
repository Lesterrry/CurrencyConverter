//
//  ViewController.swift
//  ExchangeRate
//
//  Created by Aydar Nasibullin on 30.05.2020.
//  Copyright © 2020 Fetch Development. All rights reserved.
//

import UIKit
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    struct currency : Equatable {
        var name: String
        var iconName: String
        var toDollar: Double
        var fromDollar: Double
    }
    struct answerProp: Codable{
        let rates: rates
        struct rates: Codable {
            let EUR: Double
            let JPY: Double
            let TRY: Double
            let RUB: Double
            let BRL: Double
            let ZAR: Double
            let SEK: Double
        }
    }
    
    //These exchange rates valid for file creation date
    var dollar = currency(name: "USD Американский доллар", iconName: "dollarsign.circle", toDollar: 1, fromDollar: 1)
    var ruble = currency(name: "RUB Российский рубль", iconName: "rublesign.circle", toDollar: 0.014, fromDollar: 70.75)
    var euro = currency(name: "EUR Евро", iconName: "eurosign.circle", toDollar: 1.11, fromDollar: 0.9)
    var lira = currency(name: "TRY Турецкая лира", iconName: "lirasign.circle", toDollar: 0.15, fromDollar: 6.82)
    var yen = currency(name: "JPY Японская иена", iconName: "yensign.circle", toDollar: 0.0093, fromDollar: 107.8)
    var krona = currency(name: "SEK Шведская крона", iconName: "coloncurrencysign.circle", toDollar: 0.1056, fromDollar: 9.4701)
    var real = currency(name: "BRL Бразильский реал", iconName: "bahtsign.circle", toDollar: 0.1850, fromDollar: 5.4049)
    var rand = currency(name: "ZAR Южноафриканский рэнд", iconName: "r.circle", toDollar: 0.0570, fromDollar: 17.5524)
    
    var currencies:[currency]
    var upCurrency: currency
    var downCurrency: currency
    var downSel = false;
    
    let apiCurrenciesGetRequestURL = URL(string: "https://api.exchangeratesapi.io/latest?symbols=RUB,EUR,TRY,JPY,SEK,BRL,ZAR&base=USD")!
    let defaultRelevanceLabelData = "Data Relevance: 31.05.2020 00:59"
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (currencies[row] == downCurrency && !downSel) || (currencies[row] == upCurrency && downSel){
            picker.selectRow(downSel ? currencies.firstIndex(of: downCurrency)! :
                currencies.firstIndex(of: upCurrency)!, inComponent: 0, animated: true)
            
        }else{
            if !downSel {
                upButton.setImage(UIImage(systemName: currencies[row].iconName), for: UIControl.State.normal)
                upCurrency = currencies[row]
            }
            else{
                downButton.setImage(UIImage(systemName: currencies[row].iconName), for: UIControl.State.normal)
                downCurrency = currencies[row]
            }
            update()
        }
    }
    
    init(){
        currencies = [dollar, ruble, euro, lira, yen, krona, real, rand]
        upCurrency = dollar
        downCurrency = ruble
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder a: NSCoder) {
        currencies = [dollar, ruble, euro, lira, yen, krona, real, rand]
        upCurrency = dollar
        downCurrency = ruble
        super.init(coder: a)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        apiRefresh()
    }
    @IBOutlet weak var upTextField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downTextField: UITextField!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var relevanceLabel: UILabel!
    @IBOutlet weak var warningMark: UIImageView!
    
    @IBAction func upButtonPressed(_ sender: Any) {
        view.endEditing(true);
        downSel = false;
        picker.selectRow(currencies.firstIndex(of: upCurrency)!, inComponent: 0, animated: true)
    }
    @IBAction func downButtonPressed(_ sender: Any) {
        view.endEditing(true);
        downSel = true;
        picker.selectRow(currencies.firstIndex(of: downCurrency)!, inComponent: 0, animated: true)
    }
    
    @IBAction func upTextFieldEdited(_ sender: Any) {
        update()
    }
    @IBAction func downTextFieldEdited(_ sender: Any) {
        update(reverse:true)
    }
    func update(reverse: Bool = false) {
        if !reverse{
            let changed:Double = Double(upTextField.text!) ?? 0
            let dollars:Double = changed * upCurrency.toDollar
            downTextField.text = String(format: "%.2f", dollars * downCurrency.fromDollar)
        }
        else{
            let changed:Double = Double(downTextField.text!) ?? 0
            let dollars:Double = changed * downCurrency.toDollar
            upTextField.text = String(format: "%.2f", dollars * upCurrency.fromDollar)
        }
    }
    func showError(){
        DispatchQueue.main.async {
            self.relevanceLabel.text = self.defaultRelevanceLabelData
            self.warningMark.isHidden = false
        }
    }
    func apiRefresh(){
        activityIndicator.startAnimating()
        relevanceLabel.text = "Updating data...";
        let task = URLSession.shared.dataTask(with: apiCurrenciesGetRequestURL) { (data, response, error) in
            guard let dataResponse = data,
                error == nil && response != nil
                else{
                    self.showError()
                    return
            }
            
            let decoder = JSONDecoder()
            do{
                let obj = try decoder.decode(answerProp.self, from: dataResponse)
                let rates = [obj.rates.RUB, obj.rates.EUR, obj.rates.TRY, obj.rates.JPY, obj.rates.SEK, obj.rates.BRL, obj.rates.ZAR]
                
                for i in 0...rates.count - 1{
                    let newCurrency = currency(name: self.currencies[i + 1].name, iconName: self.currencies[i + 1].iconName, toDollar: 1 / rates[i], fromDollar: rates[i])
                    self.currencies[i + 1] = newCurrency
                }
                self.upCurrency = self.currencies[0]
                self.downCurrency = self.currencies[1]
            }catch{
                self.showError()
            }
        }
        task.resume()
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        relevanceLabel.text = "Data Relevance: " + String(year)
            + "/" + String(month) + "/" + String(day) + " " + String(hour)
            + ":" + String(minute)
        activityIndicator.stopAnimating()
    }
}
