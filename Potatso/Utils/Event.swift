//
//  Event.swift
//  Potatso
//
//  Created by LEI on 7/5/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

import Foundation

enum Event: String {

    case ReceiptValidation = "ReceiptValidation"
    case ReceiptValidationResult = "ReceiptValidationResult"
    case ReceiptValidationBuy = "ReceiptValidationBuy"
    case ReceiptValidationCancel = "ReceiptValidationCancel"

}

func logEvent(_ event: Event, attributes: [String: AnyObject]?) {
    // Crashlytics Answers removed for unsigned CI builds
    NSLog("[Event] %@ %@", event.rawValue, attributes ?? [:])
}
