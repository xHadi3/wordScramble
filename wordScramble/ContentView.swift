//
//  ContentView.swift
//  wordScramble
//
//  Created by Hadi Al zayer on 24/06/1446 AH.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    @State private var totalLatters = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords , id: \.self){ word in
                        
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Section("Score"){
                    Text("Your Got \(score) words using \(totalLatters) letters ")
                }
            }
            .navigationTitle(rootWord)
            .toolbar{
                Button("rest"){
                    reset()
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("Ok"){}
            }message: {
                Text(errorMessage)
            }
        }
        
        
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
        guard answer.count > 0 else { return }
        
        
        
        guard isOriginal(word: answer) else{
            wordError(title: "word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "word not possible", message: "You can't spell that word from \(rootWord) !")
            return
        }
        guard isReal(word: answer) else{
            wordError(title: "word not recognized", message: "You can't just make them up you know!")
            return
            
        }
        
        guard isLongEnough(word: answer) else{
            wordError(title: "word is short", message: "too short you need more than 2 latters")
            return
        }
        guard isDifferent(word: answer) else{
            wordError(title: "same word", message: "that's the same word be creative")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        totalLatters += answer.count
        score += 1
        newWord = ""
    }
    
    func startGame(){
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from the bundle")
    
    }
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isLongEnough(word: String) -> Bool{
        if word.count > 2{
            return true
        } else {
            return false
        }
    }
    func isDifferent(word: String) -> Bool{
        if word != rootWord {
            return true
        }else{
            return false
        }
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }
    
    func wordError(title: String, message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func updateTotalLatters(word: String) -> Int{
        totalLatters = word.count
        return totalLatters
    }
    func reset(){
        score = 0
        totalLatters = 0
        usedWords.removeAll()
        startGame()
    }
    
}

#Preview {
    ContentView()
}
