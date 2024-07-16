//
//  JournalEntryView.swift
//  Debrief
//
//  Created by Lukas Maschmann on 5/2/24.
//

import SwiftUI
import SwiftData
import EmojiPicker

struct JournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.timestamp, order: .reverse) private var items: [JournalEntry]
    
    @State private var displayEmojiPicker: Bool = false
    @State private var selectedEmoji: Emoji?
    @State private var selectedItem: JournalEntry?
    
    var item: JournalEntry? // Optional property to accept an external item
    
    var body: some View {
        Group {
            if let item = item {
                journalEntryView(item) // Display the passed in journal entry
            } else {
                Text("No entry selected")            }
        }
    }

    @ViewBuilder
    private func journalEntryView(_ item: JournalEntry) -> some View {
        ZStack {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Text(formatDate(item.timestamp))
                        .font(.headline)
                    Button(action: {
                        selectedItem = item
                        displayEmojiPicker = true
                    }) {
                        Text(item.emoji)
                            .font(.headline)
                            .padding(8)
                            .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                            .clipShape(Circle())
                    }
                    
                }
                
                VStack {
                    Text(item.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text(formatDate(item.timestamp))
                                    .font(.headline)
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(action: {
                                    selectedItem = item
                                    displayEmojiPicker = true
                                }) {
                                    Text(item.emoji)
                                        .font(.headline)
                                        .padding(8)
                                        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding()
                    //                                    .navigationBarBackButtonHidden(true)
                    
                    
                    Spacer()
                }
                .background(Color.white)
                .cornerRadius(24)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.bottom, 0)
                .edgesIgnoringSafeArea(.all)
            }

        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        
        let dayOfMonth = Calendar.current.component(.day, from: date)
        let suffix: String
        
        if (11...13).contains(dayOfMonth % 100) {
            suffix = "th"
        } else {
            switch dayOfMonth % 10 {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default:
                suffix = "th"
            }
        }
        
        let formattedDate = dateFormatter.string(from: date)
        return "\(formattedDate)\(suffix)"
    }
}

// MARK: - Previews
#Preview {
    JournalEntryView(item: JournalEntry(timestamp: Date(), text: "Preview entry text", emoji: "📝"))
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
