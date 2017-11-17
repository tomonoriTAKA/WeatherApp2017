//
//  ViewController.swift
//  WeatherApp
//
//  Created by 高橋知憲 on 2017/11/15.
//  Copyright © 2017年 高橋知憲. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var dateLabel: [UILabel]!
    @IBOutlet var weatherImage: [UIImageView]!
    @IBOutlet var weatherLabel: [UILabel]!
    @IBOutlet var temperatureLabel: [UILabel]!
    
    let cityID: String = "030010" //盛岡市
    let source: String = "http://weather.livedoor.com/forecast/webservice/json/v1?city="

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let strUrl = source + cityID
        let url = URL(string: strUrl)
        Alamofire.request(url!).responseJSON {
            (response: DataResponse<Any>) in
            if response.result.isFailure == true {
                self.simpleAlert(title: "通信エラー", message: "通信に失敗しました")
                return
            }
            guard let val = response.result.value as? [String: Any] else {
                self.simpleAlert(title: "通信エラー", message: "通信結果がJSONではありませんでした")
                return
            }
            // responseJSONを使うと辞書形式でも扱えますが、今回はより簡単に扱うためにSwiftyJSONを利用します。
            let json = JSON(val)
            print(json)
            
            // タイトル部分
            if let title = json["title"].string {
                self.titleLabel.text = title
            }
            
            if let forecasts = json["forecasts"].array {
                
                if forecasts.count >= 3{

                    for i in 0..<forecasts.count {
                        //1日分の情報を取り出
                        let todayWeather = forecasts[i]
                        
                        //日付を取り出す
                        self.dateLabel[i].text = todayWeather["dateLabel"].stringValue + todayWeather["date"].stringValue
                        
                        //画像URLがあれば画像を表示
                        if let imgUrl = todayWeather["image"]["url"].string {
                            self.weatherImage[i].sd_setImage(with: URL(string: imgUrl))
                        }
                        //天気を表示
                        self.weatherLabel[i].text = todayWeather["telop"].stringValue
                        
                        //気温を表示
                        self.temperatureLabel[i].text = self.generateTemperatureText(todayWeather["temperature"])
                    }
               }
                
            }
        }
    }

    func simpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func generateTemperatureText(_ temperature: JSON) -> String {
        
        var resultText = ""
        
        if let min = temperature["min"]["celsius"].string {
            resultText += min + "℃"
        } else {
            resultText += "-"
        }
        
        resultText += " / "
        
        if let max = temperature["max"]["celsius"].string {
            resultText += max + "℃"
        } else {
            resultText += "-"
        }
        return resultText
    }
}

