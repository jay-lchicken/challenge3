//
//  ChatView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//
//ME (HONG YU) takes CREDITS for this ENTIRE PAGE and bro......ye......🫠
import SwiftUI
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
    

    var body: some View {
        ZStack{
            
            VStack{
                if let response = viewModel.generatedResponse?.response{
                    Text(response)
                        .opacity(viewModel.isGenerating ? 0.85 : 1.0)
                        .animation(.smooth(duration: 0.4), value: viewModel.isGenerating)
                        .scaleEffect(viewModel.isGenerating ? 0.98 : 1.0)
                        .animation(.smooth(duration: 0.3), value: viewModel.isGenerating)
                }else{
                    Text("Bro")
                        .font(.system(size:40,weight: .heavy, width: .expanded))
                    Text("Your Personal Finance Assistant")
                        .font(.system(size: 20, weight: .regular))

                }

                

                
                
            }
            .animation(.easeOut, value: viewModel.generatedResponse?.response ?? "")
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
