//
//  MailChimpAPI.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/8/16.
//  Copyright © 2016 Aaron Williamson. All rights reserved.
//

import Foundation

struct MailChimpAPI {
    
    fileprivate let baseURLString = Service.Mailchimp.url
    fileprivate let username = "Ripelist"
    fileprivate let APIKey = Service.Mailchimp.apiKey
    
    let session: URLSession = {
        let defaultConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: defaultConfiguration)
    }()
    
    func postMemberToList(_ urlRequest: URLRequest) {
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            guard let data = data else { print(error); return }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse JSON: \(jsonStr)")
                    return
                }
                print(json)
            } catch let parseError {
                print(parseError)
            }
        }) 
        task.resume()
    }
    
    func createRequest(_ name: String?, city: String, email: String) {
        guard let url = URL(string: baseURLString) else { return }
        
        let urlRequest = NSMutableURLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = NSString(format: "%@:%@", username, APIKey)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        urlRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let petitionerName = name != nil ? name! : "N/A"
        let params = ["email_address": email as AnyObject, "status": "subscribed" as AnyObject, "merge_fields": ["CITY": city, "NAME": petitionerName]] as [String: AnyObject]
        
        do { urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch let error {
            print(error)
        }
        
        self.postMemberToList(urlRequest as URLRequest)
    }
}
