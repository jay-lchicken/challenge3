//
//  ChatView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//
//ME (HONG YU) takes CREDITS for this ENTIRE PAGE and bro......ye......🫠
import SwiftUI
import FoundationModels
extension Font {
    static func system(
        size: CGFloat,
        weight: UIFont.Weight,
        width: UIFont.Width) -> Font {
            return Font(
                UIFont.systemFont(
                    ofSize: size,
                    weight: weight,
                    width: width)
            )
        }
}
struct ChatView: View {
    @FocusState private var isTextFieldFocused: Bool
    @State var viewModel = FoundationModelViewModel()
    func segmentsToString(segments: [Transcript.Segment]) -> String{
        let strings = segments.compactMap {segment -> String? in
            if case let .text(textSegment) = segment{
                return textSegment.content
            }
            return nil
            
        }
        return strings.reduce("", +)
        
    }

    var body: some View {
        ZStack{
            
            VStack{
                
                if let response = viewModel.generatedResponse?.response{
                    ScrollView{
                        ForEach(viewModel.session.transcript){ entry in
                            switch entry {
                            case .prompt(let response):
                                HStack{
                                    Spacer()
                                    Text(response.segments[0].description)
                                        .padding()
                                        .background(.blue.opacity(0.3))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                }
                            case .response(let response):
                                HStack{
                                    Text(response.segments[0].description)
                                        .padding()
                                        .background(.green.opacity(0.3))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            case .toolOutput(let response):
                                HStack{
                                    Text(response.description)
                                        .padding()
                                        .background(.orange.opacity(0.3))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            default:
                                EmptyView()
                            }
                            
                        }
                    }
                    
                }else{
                    Text("Bro")
                        .font(.system(size:40,weight: .heavy, width: .expanded))
                    Text("Your Personal Finance Assistant")
                        .font(.system(size: 20, weight: .regular))

                }

                

                
                
            }
            VStack{
                Spacer()
                HStack{
                    TextField("What would you like to do today?", text: $viewModel.query)
                        .padding()
                        .focused($isTextFieldFocused)
                        
                    Button{
                        Task{
                            await viewModel.generateResponse()

                        }
                    }label:{
                        Image(systemName: "arrow.up.circle")
                            .font(.title2)
                            .padding()
                    }

                }
                .glassEffect(.clear.interactive(), in: .capsule)
                .padding()
                .onAppear {
                            isTextFieldFocused = true
                        }
                
            }
        }
        .alert(isPresented: $viewModel.showAlert){
            Alert(title: Text("Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("awwww")))
        }
    }
}

#Preview {
    ChatView()
}
