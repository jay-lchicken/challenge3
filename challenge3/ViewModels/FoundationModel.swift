//
//  FoundationModel.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import Foundation
import FoundationModels
import Combine
@Generable
struct ModelResponse{
    @Guide(description: "The main response you have to the user's query")
    var response: String
}

class FoundationModelViewModel: ObservableObject{
    init(){}
    @Published var isGenerating: Bool = false
    @Published var query: String = ""
    @Published var generatedResponse: ModelResponse.PartiallyGenerated?
    @Published var showAlert = false
    @Published var alertMessage: String = ""
    let instructions =
    """
    Role: You are to give a reasonable explanation or response on the user's query to finance. If the user asks something that is not related, bring back the conversation to be related. English only.
    """
    lazy var session = LanguageModelSession(instructions: instructions)
    func generateResponse() async{
        isGenerating = true
        let stream = session.streamResponse(to: query, generating: ModelResponse.self)
        do{
            for try await partial in stream {
                generatedResponse = partial.content
                
            }
        }catch{
            alertMessage = error.localizedDescription
            showAlert.toggle()
            print("\(error.localizedDescription)")
        }
        

        
        
    }
    
}
