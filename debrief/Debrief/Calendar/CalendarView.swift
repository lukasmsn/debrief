//
// Debrief
// Created by  Lukas Maschmann on 2024-05-01
//


import SwiftUI
import SwiftData
import EmojiPicker

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    
    let date: Date
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    @Query private var journalEntries: [JournalEntry]
    @State private var counts = [Int : Int]()
    
    // Extension properties to display selected day's workouts
    @State private var selectedDay: Date?
    @State private var journalEntriesByDay: [JournalEntry] = []
    
    @State private var presentedJournalEntry: JournalEntry?
    
    @State private var displayEmojiPicker: Bool = false
    @State private var selectedEmoji: Emoji?
    @State private var selectedItem: JournalEntry?

    init(date: Date) {
        self.date = date
        let endOfMonthAdjustment = Calendar.current.date(byAdding: .day, value: -1, to: date.endOfMonth)!
        let predicate = #Predicate<JournalEntry> {$0.timestamp >= date.startOfMonth && $0.timestamp <= endOfMonthAdjustment}
        _journalEntries = Query(filter: predicate, sort: \JournalEntry.timestamp)
    }
    var body: some View {
        VStack {
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .fontWeight(.medium)
                        .foregroundStyle(Color.black.opacity(0.3))
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach(days, id: \.self) { day in
                    if day.monthInt != date.monthInt {
                        Text("")
                    } else {
                        VStack {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.regular)
                                .foregroundStyle(.black.opacity(0.6))
                                .frame(width: 50, height: 12)
                                .padding(.bottom, 3)
                            Text(getFirstEntryForDate(day)?.emoji ?? "")
                                .font(.system(size: 20))
                                .frame(width: 50, height: 20, alignment: .center)
                                .padding(.top, 3)
                            
                            Spacer()
                            //                                .overlay(alignment: .bottomTrailing) {
                            //                                if let count = counts[day.dayInt] {
                            //                                    Image(systemName: count <= 50 ? "\(count).circle.fill" : "plus.circle.fill")
                            //                                        .foregroundColor(.secondary)
                            //                                        .imageScale(.medium)
                            //                                        .background (
                            //                                            Color(.systemBackground)
                            //                                                .clipShape(.circle)
                            //                                        )
                            //                                        .offset(x: 5, y: 5)
                            //                                }
                            
                            
                            //                                }
                                .onTapGesture {
                                    // Used in the ExtendedProject branch
                                    if let count = counts[day.dayInt], count > 0 {
                                        selectedDay = day
                                    } else {
                                        selectedDay = nil
                                    }
                                }
                        }
                        .frame(height: 40, alignment: .top)
                        .padding(.vertical, 20)
                        .background(
                            Rectangle()
                                .cornerRadius(16)
                                .foregroundStyle(
                                    selectedDay == Date.now ? .black.opacity(0.1) :
                                        Date.now.startOfDay == day.startOfDay ? .black.opacity(0.05) :
                                            .black.opacity(0)
                                    //                                        selectedDay == Date.now ? .black.opacity(0.1) :
                                    //                                        Date.now.startOfDay == day.startOfDay
                                    //                                        ? .black.opacity(counts[day.dayInt] != nil ? 1 : 0.5)
                                    //                                        :  .yellow.opacity(counts[day.dayInt] != nil ? 0.8 : 0)
                                )
                        )
                        .onTapGesture {
                            presentedJournalEntry = getFirstEntryForDate(day)
                        }
                        
                    }
                }
            }
            //            if let selectedDay {
            //                // Presents the list of workouts for the selected day and activity
            //                JournalEntryListView(day: selectedDay, journalEntries: journalEntriesByDay)
            //            }
        }
        .padding()
        .onAppear {
            days = date.calendarDisplayDays
            setupCounts()
            selectedDay = nil // Used to present list of workouts when tapped
        }
        .onChange(of: date) {
            days = date.calendarDisplayDays
            setupCounts()
            selectedDay = nil // Used to present list of workouts when tapped
        }
        .onChange(of: selectedDay) {
            // Will filter the workouts for the specific day and activity is selected
            if let selectedDay {
                journalEntriesByDay = journalEntries.filter {$0.timestamp.dayInt == selectedDay.dayInt}
            }
        }
        .sheet(item: $presentedJournalEntry) { journalEntry in
            VStack {
                HStack {
                    Text(formatDate(journalEntry.timestamp))
                        .font(.headline)
                        .padding(.vertical)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedItem = journalEntry
                        selectedEmoji = nil
                        displayEmojiPicker = true
                    }) {
                        Text(journalEntry.emoji)
                            .font(.headline)
                            .padding(8)
                            .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                            .clipShape(Circle())
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
                }

                
                ScrollView {
                    Text(journalEntry.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
            }
            .cornerRadius(24)
            .padding()
            .presentationDetents([.medium])

        }

    }

    
    func setupCounts() {
        let filteredJournalEntries = journalEntries
        let mappedItems = filteredJournalEntries.map{($0.timestamp.dayInt, 1)}
        counts = Dictionary(mappedItems, uniquingKeysWith: +)
    }
    
    func getFirstEntryForDate(_ date: Date) -> JournalEntry? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)

        let entriesForDay = journalEntries.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay! }
        
        return entriesForDay.sorted(by: { $0.timestamp < $1.timestamp }).first
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
    CalendarView(date: Date.now)
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
