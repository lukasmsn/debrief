//
// Debrief
// Created by  Lukas Maschmann on 2024-05-01
//


import SwiftUI
import SwiftData

struct CalendarHeaderView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var monthDate = Date.now
    @State private var years: [Int] = []
    @State private var selectedMonth = Date.now.monthInt
    @State private var selectedYear = Date.now.yearInt
    @Query private var journalEntries: [JournalEntry]
    
    let months = Date.fullMonthNames
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.05)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if !journalEntries.isEmpty{
                        HStack {
                            Picker("", selection: $selectedYear) {
                                ForEach(years, id:\.self) { year in
                                    Text(String(year))
                                }
                            }
                            .accentColor(.black)
                            .background(Color.white)
                            .cornerRadius(16)
                            Picker("", selection: $selectedMonth) {
                                ForEach(months.indices, id: \.self) { index in
                                    Text(months[index]).tag(index + 1)
                                }
                                
                            }
                            .accentColor(.black)
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(.black)
                        .padding(.top, 16)
                        CalendarView(date: monthDate)
                        Spacer()
                    } else {
                        ContentUnavailableView("No Entries yet", systemImage: "questionmark.square.dashed")
                            .foregroundColor(.secondary)
                            .listRowBackground(Color.clear)
                            .onAppear {
                                // Load dummy data if list is empty
                                modelContext.insert(JournalEntry(timestamp: Date(), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.", emoji: "🎓"))
                                modelContext.insert(JournalEntry(timestamp: Date().addingTimeInterval(-86400), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.", emoji: "🚀"))
                                modelContext.insert(JournalEntry(timestamp: Date().addingTimeInterval(-86400*2), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.", emoji: "🥳"))
                            }
                    }
                }
                .background(Color.white)
                .cornerRadius(24)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 104)
                .padding(.bottom, 0)
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            years = Array(Set(journalEntries.map {$0.timestamp.yearInt}.sorted()))
        }
        .onChange(of: selectedYear) {
            updateDate()
        }
        .onChange(of: selectedMonth) {
            updateDate()
        }
    }
    
    func updateDate() {
        monthDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!
    }
}

#Preview {
    CalendarHeaderView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}
