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
    let apiCurrenciesGetRequestURL = URL(string: "https://api.exchangeratesapi.io/latest?symbols=EUR,USD&base=RUB")!
    struct answerProp: Codable{
        let rates: rates
        struct rates: Codable {
            let EUR: Double
            let USD: Double
        }
    }
    
    @IBOutlet weak var USDexchangeRate: UILabel!
    @IBOutlet weak var EURexchangeRate: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let task = URLSession.shared.dataTask(with: apiCurrenciesGetRequestURL) { (data, response, error) in
            let dataResponse = data
            if error == nil && response != nil{
                
                let decoder = JSONDecoder()
                do{
                    let obj = try decoder.decode(answerProp.self, from: dataResponse!)
                    DispatchQueue.main.async {
                        self.USDexchangeRate.text = String(format: "%.1f", 10000000000 / (obj.rates.USD * 10000000000))
                        self.EURexchangeRate.text = String(format: "%.1f", 10000000000 / (obj.rates.EUR * 10000000000))
                    }
                }catch{
                    self.USDexchangeRate.text = "--.-"
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
