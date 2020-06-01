//
//  ViewController.swift
//  ExchangeRate
//
//  Created by Aydar Nasibullin on 30.05.2020.
//  Copyright © 2020 Fetch Development. All rights reserved.
//

import UIKit
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    struct Currency: Equatable {
        var name: String
        var iconName: String
        var toDollar: Double
        var fromDollar: Double
    }
    struct AnswerProp: Codable {
        let time_last_update_utc: String
        let conversion_rates: Rates
        struct Rates: Codable {
            let EUR: Double
            let JPY: Double
            let TRY: Double
            let RUB: Double
            let BRL: Double
            let ZAR: Double
            let SEK: Double
        }
    }
    //These exchange Rates valid for file creation date
    var dollar = Currency(name: "USD Американский доллар", iconName: "dollarsign.circle", toDollar: 1, fromDollar: 1)
    var ruble = Currency(name: "RUB Российский рубль", iconName: "rublesign.circle", toDollar: 0.014, fromDollar: 70.75)
    var euro = Currency(name: "EUR Евро", iconName: "eurosign.circle", toDollar: 1.11, fromDollar: 0.9)
    var lira = Currency(name: "TRY Турецкая лира", iconName: "lirasign.circle", toDollar: 0.15, fromDollar: 6.82)
    var yen = Currency(name: "JPY Японская иена", iconName: "yensign.circle", toDollar: 0.0093, fromDollar: 107.8)
    var krona = Currency(name: "SEK Шведская крона", iconName: "coloncurrencysign.circle", toDollar: 0.1056,
                         fromDollar: 9.4701)
    var real = Currency(name: "BRL Бразильский реал", iconName: "bahtsign.circle", toDollar: 0.1850, fromDollar: 5.4049)
    var rand = Currency(name: "ZAR Южноафриканский рэнд", iconName: "r.circle", toDollar: 0.0570, fromDollar: 17.5524)
    
    var currencies: [Currency]
    var upCurrency: Currency
    var downCurrency: Currency
    var downSel = false
    
    let apiCurrenciesGetRequestURL = URL(string:
        "https://v6.exchangerate-api.com/v6/93dace697f07f94d224cc61d/latest/USD")!
    let defaultRelevanceLabelData = "Data Relevance: Thu, 31 May 2020 00:59:01"
    
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
        if (currencies[row] == downCurrency && !downSel) || (currencies[row] == upCurrency && downSel) {
            picker.selectRow(downSel ? currencies.firstIndex(of: downCurrency)! :
                currencies.firstIndex(of: upCurrency)!, inComponent: 0, animated: true)
            
        } else {
            if !downSel {
                upButton.setImage(UIImage(systemName: currencies[row].iconName), for: UIControl.State.normal)
                upCurrency = currencies[row]
            } else{
                downButton.setImage(UIImage(systemName: currencies[row].iconName), for: UIControl.State.normal)
                downCurrency = currencies[row]
            }
            update()
        }
    }
    
    init () {
        currencies = [dollar, ruble, euro, lira, yen, krona, real, rand]
        upCurrency = dollar
        downCurrency = ruble
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder nscoder: NSCoder) {
        currencies = [dollar, ruble, euro, lira, yen, krona, real, rand]
        upCurrency = dollar
        downCurrency = ruble
        super.init(coder: nscoder)
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
        view.endEditing(true)
        downSel = false
        picker.selectRow(currencies.firstIndex(of: upCurrency)!, inComponent: 0, animated: true)
    }
    @IBAction func downButtonPressed(_ sender: Any) {
        view.endEditing(true)
        downSel = true
        picker.selectRow(currencies.firstIndex(of: downCurrency)!, inComponent: 0, animated: true)
    }
    
    @IBAction func upTextFieldEdited(_ sender: Any) {
        update()
    }
    @IBAction func downTextFieldEdited(_ sender: Any) {
        update(reverse: true)
    }
    func update(reverse: Bool = false) {
        if !reverse {
            let changed: Double = Double(upTextField.text!) ?? 0
            let dollars: Double = changed * upCurrency.toDollar
            downTextField.text = String(format: "%.2f", dollars * downCurrency.fromDollar)
        }
        else {
            let changed: Double = Double(downTextField.text!) ?? 0
            let dollars: Double = changed * downCurrency.toDollar
            upTextField.text = String(format: "%.2f", dollars * upCurrency.fromDollar)
        }
    }
    func showError() {
        DispatchQueue.main.async {
            self.relevanceLabel.text = self.defaultRelevanceLabelData
            self.warningMark.isHidden = false
        }
    }
    func apiRefresh() {
        activityIndicator.startAnimating()
        relevanceLabel.text = "Updating data..."
        let task = URLSession.shared.dataTask(with: apiCurrenciesGetRequestURL) { (data, response, error) in
            guard let dataResponse = data,
                error == nil && response != nil
                else {
                    self.showError()
                    return
            }
            
            let decoder = JSONDecoder()
            do {
                let obj = try decoder.decode(AnswerProp.self, from: dataResponse)
                let rates = [obj.conversion_rates.RUB, obj.conversion_rates.EUR, obj.conversion_rates.TRY,
                             obj.conversion_rates.JPY, obj.conversion_rates.SEK, obj.conversion_rates.BRL,
                             obj.conversion_rates.ZAR]
                
                for i in 0...rates.count - 1 {
                    let newCurrency = Currency(name: self.currencies[i + 1].name,
                                               iconName: self.currencies[i + 1].iconName,
                                               toDollar: 1 / rates[i], fromDollar: rates[i])
                    self.currencies[i + 1] = newCurrency
                }
                self.upCurrency = self.currencies[0]
                self.downCurrency = self.currencies[1]
                DispatchQueue.main.async {
                    self.relevanceLabel.text = "Data Relevance: " + obj.time_last_update_utc.split(separator: "+")[0]
                }
            } catch {
                self.showError()
            }
        }
        task.resume()
        activityIndicator.stopAnimating()
    }
}
