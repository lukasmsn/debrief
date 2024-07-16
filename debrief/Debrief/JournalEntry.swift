//
//  Item.swift
//  Debrief
//
//  Created by Mikkel Svartveit on 4/18/24.
//

import Foundation
import SwiftData

@Model
final class JournalEntry {
    var timestamp: Date
    var text: String
    var emoji: String
    
    init(timestamp: Date, text: String, emoji: String) {
        self.timestamp = timestamp
        self.text = text
        self.emoji = emoji
    }
}
