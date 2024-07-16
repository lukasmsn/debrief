//
//  WritingView.swift
//  Debrief
//
//  Created by Mikkel Svartveit on 4/18/24.
//

import SwiftUI
import SwiftData

struct WritingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var isTextEditorFocused: Bool
    @FocusState private var isEmojiFieldFocused: Bool

    
    @State private var text = ""
    @State private var previousText = ""
    
    @State private var timerStartTime = 5.0
    @State private var timeRemaining = 5.0
    @State private var isTimerRunning = true
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.05)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                TextEditor(text: $text)
                    .onChange(of: text) { newValue, _ in
                        if newValue.count > previousText.count {
                            resetTimer()
                        }
                        previousText = newValue
                    }
                    .focused($isTextEditorFocused)
                    .onAppear {
                        isTextEditorFocused = true
                    }
                    .padding(10)
                    .background(Color(.white))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .foregroundColor(.white)
//                    )
//                    .cornerRadius(24)

            }
            .padding(.top, 40)
            .cornerRadius(24)



            VStack {
                Spacer()
                HStack() {
                    Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .imageScale(.large)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color.black)
                                }
                                .frame(width: 40, height: 40)
                                .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    Spacer()
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                            .frame(width: 100, height: 12)
                            .cornerRadius(.infinity)
                            .zIndex(1)
                        Rectangle()
                            .fill(timeRemaining <= 2.5 ? Color.red : Color.black)
                            .frame(width: (timeRemaining/timerStartTime)*100, height: 12)
                            .cornerRadius(.infinity)
                            .padding(.trailing, (1 - timeRemaining/timerStartTime) * 100)
                            .onReceive(timer) { _ in
                                if isTimerRunning {
                                    if timeRemaining > 0.01 {
                                        timeRemaining -= 0.01
                                    } else {
                                        isTimerRunning = false
                                        vibrate()
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                            .zIndex(0)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: .infinity))
                    .alignmentGuide(.leading) { _ in
                        0
                    }
                    Spacer()
                    Button(action: saveEntry, label: {
                        Image(systemName: "paperplane.fill")
                            .imageScale(.large)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.black)
                    })
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
            }
        }
        .frame(maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
    }

    
    private func resetTimer() {
        timeRemaining = 5.0
    }
    
    private func saveEntry() {
        withAnimation {
            let newItem = JournalEntry(timestamp: Date(), text: text, emoji: "⏳")
            modelContext.insert(newItem)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func vibrate() {
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.error)
    }
}


#Preview {
    WritingView()
}
