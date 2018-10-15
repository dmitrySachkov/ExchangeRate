//
//  SecondViewController.swift
//  ExchangeRate
//
//  Created by Дмитрий on 21.09.18.
//  Copyright © 2018 Sachkov Dmitry. All rights reserved.
//

import UIKit

struct Valute {
    let numCode: Int
    var charCode: String
    let nominal: Int
    let name: String
    let value: Decimal
}

class SecondViewController: UIViewController, XMLParserDelegate {

    @IBOutlet weak var usdView: UILabel!
    @IBOutlet weak var eurView: UILabel!
    
    
    var dateStr = ""
    
    var numCodeStr: String = ""
    var charCode: String = ""
    var nominalStr: String = ""
    var name: String = ""
    var valueStr: String = ""
    

    var currentParsingText: String? = nil
    

    var valuteArr: [Valute] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print (dateStr)
        
        getXMLDataFromServer()
        print(valuteArr.enumerated())
    }
    
    func getXMLDataFromServer() {

        
        guard let url = URL(string: "https://www.cbr.ru/scripts/XML_daily.asp?date_req=\(dateStr)") else {
            print("URL is wrong")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print("dataTaskWhithRequest error: \(error)")
                } else {
                    print("Unexpected nil") 
                }
                return
            }

            self.valuteArr = []
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            //### Call your UI update here.
            if let error = parser.parserError {
                print(error)
            } else {
                DispatchQueue.main.async {
                    self.displayOnUI()
                }
            }
        }
        task.resume()
    }
    

    func parser(_ parser: XMLParser,didStartElement elementName: String, namespaceURI namespaceURl: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {

        switch elementName {
        case "ValCurs":
            print ("Found root element...")
        case "Valute":

            numCodeStr = ""
            charCode = ""
            nominalStr = ""
            name = ""
            valueStr = ""
        case "NumCode", "CharCode", "Nominal", "Name", "Value":

            currentParsingText = ""
        default:
            print("Unexected element:", elementName)
        }
    }
    

    func parser(_ parser: XMLParser, foundCharacters string: String) {

        currentParsingText? += string
    }
    

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        switch elementName {
        case "ValCurs":
            print ("End root element...")
        case "Valute":
           
            guard let numCode = Int(numCodeStr), let nominal = Int(nominalStr),
                let value = Decimal(string: valueStr.replacingOccurrences(of: ",", with: "."))
                else {
                    print("Some entry cannot be parsed as number: NumCode: \(numCodeStr), Nominal: \(nominalStr), value: \(valueStr)")
                    return
            }
            let newValute = Valute(numCode: numCode, charCode: charCode, nominal: nominal, name: name, value: value)
            valuteArr.append(newValute)
         
                case "NumCode":
            numCodeStr = currentParsingText ?? ""
            currentParsingText = nil
        case "CharCode":
            charCode = currentParsingText ?? ""
            currentParsingText = nil
        case "Nominal":
            nominalStr = currentParsingText ?? ""
            currentParsingText = nil
        case "Name":
            name = currentParsingText ?? ""
            currentParsingText = nil
        case "Value":
            valueStr = currentParsingText ?? ""
            currentParsingText = nil
        default:
            print("Unexected end element:", elementName)
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print ("Started parsing...")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
       
        print ("end parsing...")
    }
    
    func parser(_parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parseErrorOccurred: \(parseError)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func displayOnUI() {
      
        self.usdView.text = "\(valuteArr[4].value)"
        self.eurView.text = "\(valuteArr[5].value)"
        
    }

}
