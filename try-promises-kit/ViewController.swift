//
//  ViewController.swift
//  try-promises-kit
//
//  Created by WingCH on 4/2/2020.
//  Copyright © 2020 WingCH. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    let backendUrl = URL(string: "https://muddy-band-6107.wingch.workers.dev/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func clickBtn(_ sender: Any) {
        //        useCallback()
        //let request = URLRequest(url:backendUrl!)
        usePromise()
    }
    
    fileprivate func useCallback() {
        //get image url
        URLSession.shared.dataTask(with: backendUrl!) { data, _, error in
            if error != nil {
                print(error!)
                return
            }
            
            let imageurl = String(data: data!, encoding: String.Encoding.utf8) as String? // For simplicity response is only the URL
            
            //get image using image url
            URLSession.shared.dataTask(with: URL(string:imageurl!)!) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data!)
                }
            }.resume()
        }.resume()
    }
    
    fileprivate func usePromise() {
        
        func fetchPromise(url: URL) -> Promise<Data> {
            return Promise { resolver in
                URLSession.shared.dataTask(with: url) { data, _, error in
                    // error ? reject : fulfill
                    resolver.resolve(data, error)
                }.resume()
            }
        }
        
        func getUrlPromise(data: Data) -> Promise<URL> {
            return Promise<URL> { resolver in
                
                // For simplicity response is only the URL
                let imageurl = String(data: data, encoding: String.Encoding.utf8) as String?
                
                if let request = URL(string:imageurl!){
                    resolver.fulfill(request)
                }else{
                    resolver.reject(CustomError.convertUrlProblem)
                }
            }
        }
        
        fetchPromise(url: backendUrl!).then{ data in
            return getUrlPromise(data: data)
        }.then{ data in
            return fetchPromise(url: data)
        }.done { data in
            self.imageView.image = UIImage(data: data)
        }.catch{
            error in
            print(error.localizedDescription)
        }
        
        
        fetchPromise(url: backendUrl!)
            .then(getUrlPromise)
            .then(fetchPromise)
            .done{ data in
                self.imageView.image = UIImage(data: data)
        }.catch{
            error in
            print(error.localizedDescription)
        }
    }
}

enum CustomError:Error {
    case convertUrlProblem
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .convertUrlProblem:
            return NSLocalizedString("Cannot convert data to Url", comment: "")
        }
    }
}
