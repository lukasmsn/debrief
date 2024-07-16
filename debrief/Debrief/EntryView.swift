////
////  EntryView.swift
////  Debrief
////
////  Created by Lukas Maschmann on 5/2/24.
////
//
//import SwiftUI
//import SwiftData
//import EmojiPicker
//
//
//struct EntryView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query(sort: \JournalEntry.timestamp, order: .reverse) private var items: [JournalEntry]
//    
//    @State private var displayEmojiPicker: Bool = false
//    @State private var selectedEmoji: Emoji?
//    @State private var selectedItem: JournalEntry?
//    
//    
//    var body: some View {
//        if items.isEmpty {
//            Text("No journal entries yet!")
//                .foregroundColor(.secondary)
//                .listRowBackground(Color.clear)
//                .onAppear {
//                    // Load dummy data if list is empty
//                    modelContext.insert(JournalEntry(timestamp: Date(), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.", emoji: "🎓"))
//                    modelContext.insert(JournalEntry(timestamp: Date().addingTimeInterval(-86400), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.", emoji: "🚀"))
//                    modelContext.insert(JournalEntry(timestamp: Date().addingTimeInterval(-86400*2), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.", emoji: "🥳"))
//                }
//        } else {
//            Text(item.text)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Text(formatDate(item.timestamp))
//                            .font(.headline)
//                    }
//                }
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: {
//                            selectedItem = item
//                            displayEmojiPicker = true
//                        }) {
//                            Text(item.emoji)
//                                .font(.headline)
//                                .padding(8)
//                                .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
//                                .clipShape(Circle())
//                        }
//                    }
//                }
//                .padding()
////                                    .navigationBarBackButtonHidden(true)
//
//            
//            Spacer()
//        }
//        }
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMMM d"
//        
//        let dayOfMonth = Calendar.current.component(.day, from: date)
//        let suffix: String
//        
//        if (11...13).contains(dayOfMonth % 100) {
//            suffix = "th"
//        } else {
//            switch dayOfMonth % 10 {
//            case 1:
//                suffix = "st"
//            case 2:
//                suffix = "nd"
//            case 3:
//                suffix = "rd"
//            default:
//                suffix = "th"
//            }
//        }
//        
//        let formattedDate = dateFormatter.string(from: date)
//        return "\(formattedDate)\(suffix)"
//    }
//}
//
//#Preview {
//    EntryView()
//        .modelContainer(for: JournalEntry.self, inMemory: true)
//}
