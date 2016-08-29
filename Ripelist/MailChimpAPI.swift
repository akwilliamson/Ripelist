//
//  MailChimpAPI.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/8/16.
//  Copyright © 2016 Aaron Williamson. All rights reserved.
//

import Foundation

struct MailChimpAPI {
    
    private let baseURLString = Service.Mailchimp.url
    private let username = "Ripelist"
    private let APIKey = Service.Mailchimp.apiKey
    
    let session: NSURLSession = {
        let defaultConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: defaultConfiguration)
    }()
    
    func postMemberToList(urlRequest: NSURLRequest) {
        let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
            
            guard let data = data else { print(error); return }
            
            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary else {
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                    return
                }
                print(json)
            } catch let parseError {
                print(parseError)
            }
        }
        task.resume()
    }
    
    func createRequest(name: String?, city: String, email: String) {
        guard let url = NSURL(string: baseURLString) else { return }
        
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = NSString(format: "%@:%@", username, APIKey)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        urlRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let petitionerName = name != nil ? name! : "N/A"
        let params = ["email_address": email, "status": "subscribed", "merge_fields": ["CITY": city, "NAME": petitionerName]] as [String: AnyObject]
        
        do { urlRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error {
            print(error)
        }
        
        self.postMemberToList(urlRequest)
    }
}