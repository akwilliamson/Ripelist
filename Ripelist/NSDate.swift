//
//  NSDate.swift
//  Ripelist
//
//  Created by Aaron Williamson on 9/16/15.
//  Copyright © 2015 Aaron Williamson. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoSinceDate() -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(self)
        let latest = earliest == now ? self : now
        let components: DateComponents = (calendar as NSCalendar).components([.minute, .hour, .day, .weekOfYear], from: earliest, to: latest, options: [])
        
        if components.weekOfYear! >= 2 {
            return "> 2 weeks ago"
        } else if components.weekOfYear! >= 1 {
            return "1 week ago"
        } else if components.day! >= 2 {
            return "\(components.day) days ago"
        } else if components.day! >= 1 {
            return "1 day ago"
        } else if components.hour! >= 2 {
            return "\(components.hour) hours ago"
        } else if components.hour! >= 1 {
            return "1 hour ago"
        } else if components.minute! >= 2 {
            return "\(components.minute) minutes ago"
        } else if components.minute! >= 1 {
            return "1 minute ago"
        } else {
            return "Just now"
        }
    }
}
