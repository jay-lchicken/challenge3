//
//  ChatView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//
//ME (HONG YU) takes CREDITS for this ENTIRE PAGE and bro......ye......🫠
import SwiftUI
import FoundationModels
import Markdown
import MarkdownUI
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

struct GetExpenseToolArgument: Decodable {
    let daysToLookBack: Int
}

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @FocusState private var isTextFieldFocused: Bool
    @State var viewModel = FoundationModelViewModel()
    @State var scrollPosition = ScrollPosition()

    func segmentsToString(segments: [Transcript.Segment]) -> String{
        let strings = segments.compactMap {segment -> String? in
            if case let .text(textSegment) = segment{
                return textSegment.content
            }
            return nil
        }
        return strings.reduce("", +)
    }

    func daysToLookBack(_ x: String) -> Int {
        guard let jsonData = x.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let days = json["daysToLookBack"] as? Int else {
            return 0
        }
        return days
    }

    var body: some View {
        ZStack{
            VStack{
                if viewModel.session.transcript.count != 1{
                    NavigationView{
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
                                        Markdown(
                                                    response.segments[0].description)
                                                                                .padding()
                                                                                .background(.green.opacity(0.3))
                                                                                .cornerRadius(12)
                                                                                .padding(.horizontal)
                                                                            Spacer()
                                                                        }
                                case .toolOutput(let response):
                                    if response.toolName == "addExpense"{
                                        HStack{
                                            if (response.segments[0].description == "false"){
                                                Text("Failed to add expense")
                                                    .padding()
                                                    .background(.red.opacity(0.3))
                                                    .cornerRadius(12)
                                                    .padding(.horizontal)
                                            }else{
                                                Text("+\(response.segments[0].description)")
                                                    .padding()
                                                    .background(.green.opacity(0.3))
                                                    .cornerRadius(12)
                                                    .padding(.horizontal)
                                                if (undoManager?.canUndo == true){
                                                    Button{
                                                        undoManager?.undo()
                                                    }label:{
                                                        Text("Revert")
                                                            .padding()
                                                            .glassEffect(.clear.interactive())
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }
                                    }

                                case .toolCalls(let response):
                                    if response[0].toolName == "getExpense"{
                                        HStack{
                                            Text("Read Expense")
                                                .padding()
                                                .background(.green.opacity(0.3))
                                                .cornerRadius(12)
                                                .padding(.horizontal)
                                            Spacer()
                                        }
                                    }else if response[0].toolName == "getIncome"{
                                        HStack{
                                            Text("Read Income")
                                                .padding()
                                                .background(.green.opacity(0.3))
                                                .cornerRadius(12)
                                                .padding(.horizontal)
                                            Spacer()
                                        }

                                    }

                                default:
                                    EmptyView()
                                }
                            }
                            if let last = viewModel.session.transcript.last {
                                switch last{
                                case .prompt(let response):
                                    HStack{
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .padding()
                                            .background(.green.opacity(0.3))
                                            .cornerRadius(12)
                                            .padding(.horizontal)
                                        Spacer()
                                    }
                                    
                                
                                default:
                                    EmptyView()
                                }
                                
                                
                            }
                            Spacer(minLength: 100)
                        }
                        .scrollPosition($scrollPosition)
                        .navigationTitle("Bro")
                        .sensoryFeedback(.increase, trigger: viewModel.generatedResponse)

                        .onChange(of: viewModel.generatedResponse, {
                            withAnimation{
                                scrollPosition.scrollTo(edge: .bottom)
                            }
                        })
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
