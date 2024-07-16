//
//  ContentView.swift
//  Debrief
//
//  Created by Mikkel Svartveit on 4/18/24.
//

import SwiftUI
import SwiftData
import EmojiPicker

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.timestamp, order: .reverse) private var items: [JournalEntry]
    
    @State private var displayEmojiPicker: Bool = false
    @State private var selectedEmoji: Emoji?
    @State private var selectedItem: JournalEntry?
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if items.isEmpty {
                        Text("No journal entries yet!")
                            .foregroundColor(.secondary)
                            .listRowBackground(Color.clear)
                            .onAppear {
                                // Load dummy data if list is empty
                                generateSampleData()
                            }
                    } else {
                        ForEach(items) { item in
                            NavigationLink {
                                ZStack {
                                    Color.black.opacity(0.05)
                                        .edgesIgnoringSafeArea(.all)
                                    VStack {
                                        ScrollView {
                                            Text(item.text)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(4)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(24)
                                        .frame(maxWidth: .infinity, alignment: .top)
                                        .padding(.top, 104)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                    .ignoresSafeArea(.all)
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
                                                selectedEmoji = nil
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
                                }
                            } label: {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        Text(formatDate(item.timestamp))
                                            .fontWeight(.semibold)
                                        Text(item.text)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                        Spacer()
                                    }
                                    Spacer()
                                    VStack {
                                        Spacer()
                                        Button(action: {
                                            selectedItem = item
                                            selectedEmoji = nil
                                            displayEmojiPicker = true
                                        }) {
                                            Text(item.emoji)
                                                .padding(8)
                                                .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                                                .clipShape(Circle())
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        .onDelete(perform: deleteItems)
                    }
                    
                }
                .sheet(isPresented: $displayEmojiPicker, onDismiss: {
                    selectedItem?.emoji = selectedEmoji?.value ?? selectedItem?.emoji ?? ""
                }) {
                    NavigationView {
                        EmojiPickerView(selectedEmoji: $selectedEmoji, selectedColor: .orange)
                            .navigationTitle("Emojis")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .listStyle(PlainListStyle())
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink {
                            CalendarHeaderView()
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                            Text("Calendar View")
                                                .font(.headline)
                                    }
                                }
                        } label: {
                            Image(systemName: "calendar")
                                    .foregroundColor(.black)
                        }
                        .foregroundColor(.black)
                        
                        Text("")
                        
                    }
                    ToolbarItem(placement: .principal) {
                        Image("Logo")
                            .resizable()
                            .frame(width: 24, height: 28)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                            .foregroundColor(.black)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: WritingView()) {
                            Image(systemName: "highlighter")
                                .imageScale(.large)
                                .frame(width: 52, height: 52)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color(red: 38/255, green: 38/255, blue: 38/255))
                                .clipShape(Circle())
                        }
                        .navigationBarBackButtonHidden(true)
                        .padding(8)
                        .edgesIgnoringSafeArea(.all)
                        
                    }
                }
                .padding(.bottom, 16)
                .padding(.trailing, 16)
            }
        }
    }
    
    private func generateSampleData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Fixed locale

        // Start and end dates
        let startDate = dateFormatter.date(from: "2024-04-01")!
        let endDate = dateFormatter.date(from: "2024-05-02")!

        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            let entryText = generateTextForDate(currentDate)
            let emoji = generateEmojiForDate(currentDate)
            
            let newEntry = JournalEntry(timestamp: currentDate, text: entryText, emoji: emoji)
            modelContext.insert(newEntry) // Assuming modelContext is an array for simplicity
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
//        print("Entries created: \(modelContext.count)") // Debug output to confirm data creation
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func generateTextForDate(_ date: Date) -> String {
        // Randomize entry types to vary the content more naturally
        let entryType = Int.random(in: 1...7)
        switch entryType {
        case 1:
            return "Just started reading this new book on psychology and wow, it's like every page turns a light on in my brain. Can’t stop thinking about why we do what we do, and it’s all blending into thoughts about my morning walk, where the river seemed like it was speaking through ripples, telling me to slow down, reflect, and maybe change my course a bit, you know?"
        case 2:
            return "Today’s been a whirlwind of planning and setting goals, like there’s this buzz in my head full of ideas and what-ifs. Dived into cooking tonight, something totally new, and it wasn’t half bad! It’s like my taste buds are on an adventure, matching my mind’s sprint through projects and plans."
        case 3:
            return "Caught this workshop on data analytics today and my mind’s racing with all these tools and methods I learned. It’s like holding a map that shows hidden treasure trails in mountains of data. Started applying these tools right away and it’s addictive seeing patterns emerge, feels like being a detective in a data jungle."
        case 4:
            return "Deadline day and it’s crunch time, everyone’s pushing their limits and I’m right there with them. Stress levels high but we’re a good team. Unwound with some yoga tonight and it’s like my mind just unclenched, letting thoughts flow more softly, reminding me to breathe, stretch, and relax."
        case 5:
            return "Had coffee with an old friend and our conversation just danced from travels to books, from silly old times to deep new dreams. It’s energizing, talking and sharing like that, makes you see things new. Got home and jotted down a bunch of books and places to visit, like a mini treasure chest of ideas to explore."
        case 6:
            return "Plans are shaping up for a cool weekend, thinking of a little get-together, maybe some chill time with friends. Ended the day binging that new series, it’s like diving into another world where you can forget the weekly grind and just float in stories."
        case 7:
            return "Spent the day indulging in my hobbies, which is like a breath of fresh air. Found some great stuff shopping and spent hours at the cafe sketching out random thoughts and scenes, like capturing bits of the world on paper. It’s freeing, getting lost in creativity, feels like I’m exactly where I need to be."
        default:
            return "Today’s been a cascade of thoughts and tasks, a real mental marathon. Reflecting tonight, just trying to slow down the rush, breathe in peace and breathe out the noise. It’s my little ritual, helps keep the chaos at bay and cherish the small wins of the day."
        }
    }

    
    private func generateEmojiForDate(_ date: Date) -> String {
        let emojis = ["🎓", "🚀", "🥳", "📘", "🔬", "🌍", "🖼", "🎨", "🏄‍♂️"]
        let dayOfMonth = Calendar.current.component(.day, from: date)
        return emojis[dayOfMonth % emojis.count]
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


#Preview {
    ContentView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
