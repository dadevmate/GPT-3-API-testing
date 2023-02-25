//
//  ContentView.swift
//  GPT-3 API
//
//  Created by Nethan on 25/2/23.
//

import SwiftUI
import OpenAISwift
import AVFoundation
final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "API_KEY")
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case.failure:
                break
            }
        })
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    @State var synthesizer = AVSpeechSynthesizer()
    @State var mic = false
    @FocusState var focus:Bool
    var body: some View {
        
        NavigationView {
            VStack {
                  Text("Please wait for a few seconds in between requests for ChatGPT to process it.")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    List(models, id: \.self) { string in
                        
                        if string.contains("ChatGPT:") {
                            Text(string)
                            .foregroundColor(.green)
                            .fontWeight(.light)
                        } else {
                            Text(string)
                                .foregroundColor(.red)
                                .fontWeight(.light)
                      
                        }
                        
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                mic.toggle()
                            } label: {
                                if mic {
                                    Image(systemName: "speaker.wave.3.fill")
                                   
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "speaker.slash.fill")
                              
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        ToolbarItemGroup(placement: .keyboard) {
                          
                                Button("Done") {
                                    focus = false
                                }
                            
                        }
                    }
                Spacer()
                    HStack {
                        TextEditor(text: $text)
                            .frame(width: 300, height: 70)
                            .border(Color.secondary)
                            .focused($focus)
                        
                        Button {
                            
                  
                                send()
                            
                                                      
                        } label: {
                   
                                Image(systemName: "paperplane.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                        
                            
                        }
                        
                    }
                
            }
            .navigationTitle("Nethan's ChatGPT")
        }
    
        
        .onAppear {
            viewModel.setup()
        }
        .padding()
    }
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        models.append("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
       
                self.models.append("ChatGPT: \(response)")
                self.text = ""
           
                if mic {
                    let utterance = AVSpeechUtterance(string: "\(response)")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    utterance.rate = 0.5
                    
                    synthesizer.speak(utterance)
                }
              
            }
          
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
