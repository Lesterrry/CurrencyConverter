//
//  TodayViewController.swift
//  Widget
//
//  Created by Lesterrry on 31.05.2020.
//  Copyright © 2020 Fetch Development. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    let apiCurrenciesGetUSDRequestURL =
        URL(string: "https://v6.exchangerate-api.com/v6/93dace697f07f94d224cc61d/latest/USD")!
    let apiCurrenciesGetEURRequestURL =
        URL(string: "https://v6.exchangerate-api.com/v6/93dace697f07f94d224cc61d/latest/EUR")!
     struct AnswerProp: Codable {
           let conversion_rates: Rates
           struct Rates: Codable {
               let RUB: Double
           }
       }
    @IBOutlet weak var USDexchangeRate: UILabel!
    @IBOutlet weak var EURexchangeRate: UILabel!
    @IBAction func updButtonPressed(_ sender: Any) {
        performUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
       performUpdate()
    }
    
    func performUpdate() {
        widgetUpdate(label: USDexchangeRate, url: apiCurrenciesGetUSDRequestURL)
        widgetUpdate(label: EURexchangeRate, url: apiCurrenciesGetEURRequestURL)
    }
    
    func widgetUpdate(label: UILabel, url: URL) {
        label.text = "--.-"
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let dataResponse = data
            if error == nil && response != nil {
                let decoder = JSONDecoder()
                do {
                    let obj = try decoder.decode(AnswerProp.self, from: dataResponse!)
                    DispatchQueue.main.async {
                        label.text = String(format: "%.1f", obj.conversion_rates.RUB)
                    }
                } catch {
                    label.text = "--.-"
                }
            }
        }
        task.resume()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
