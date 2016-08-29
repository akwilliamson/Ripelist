//
//  Utilities.swift
//  Ripelist
//
//  Created by Aaron Williamson on 4/24/15.
//  Copyright (c) 2015 Aaron Williamson. All rights reserved.
//

import Foundation

// Converts the createdAt time of a post to a readable "time ago" string from the current time.

func timeAgoSinceDate(date: NSDate, numericDates: Bool) -> String {
    
    let calendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let earliest = now.earlierDate(date)
    let latest = earliest == now ? date : now
    let components: NSDateComponents = calendar.components([.Minute, .Hour, .Day, .WeekOfYear], fromDate: earliest, toDate: latest, options: [])
    
    if components.weekOfYear >= 2 {
        return "> 2 weeks ago"
    } else if components.weekOfYear >= 1 {
        if numericDates {
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if components.day >= 2 {
        return "\(components.day) days ago"
    } else if components.day >= 1 {
        if numericDates {
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if components.hour >= 2 {
        return "\(components.hour) hours ago"
    } else if components.hour >= 1 {
        if numericDates {
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if components.minute >= 2 {
        return "\(components.minute) minutes ago"
    } else if components.minute >= 1 {
        if numericDates {
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else {
        return "Just now"
    }
    
}
