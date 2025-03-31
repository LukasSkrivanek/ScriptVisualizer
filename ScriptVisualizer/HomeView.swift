//
//  ContentView.swift
//  TaskTry
//
//  Created by macbook on 27.04.2024.
//
import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel
    @State private var isHoveringRunButton = false
    
    var body: some View {
        HSplitView {
            inputPanel
                .frame(minWidth: 300, idealWidth: 400)
            
            outputPanel
                .frame(minWidth: 300, idealWidth: 400)
        }
        .padding()
        .frame(minWidth: 800, minHeight: 600)
    }
    
    // MARK: - Input Panel
    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Script Editor")
                .font(.title2.bold())
                .padding(.bottom, 4)
            
            // File path input
            VStack(alignment: .leading, spacing: 4) {
                Text("File Path:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("Enter script path or type below", text: $viewModel.filePath)
                        .textFieldStyle(.roundedBorder)
                        .disabled(!viewModel.scriptText.isEmpty)
                    
                    Button {
                        viewModel.filePath = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .opacity(viewModel.filePath.isEmpty ? 0 : 1)
                }
            }
            
            // Code editor
            VStack(alignment: .leading, spacing: 4) {
                Text("Or write your script:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextView(text: $viewModel.scriptText, coloredStrings: viewModel.coloredStrings)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
            }
        }
        .padding()
    }
    
    // MARK: - Output Panel
    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Output")
                    .font(.title2.bold())
                
                Spacer()
                
                // Run button with better styling
                Button(action: {
                    viewModel.executeScript()
                    viewModel.lastExitCodeVisible = true
                }) {
                    Label("Run Script", systemImage: "play.fill")
                        .font(.body.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(viewModel.isRunning || (viewModel.scriptText.isEmpty && viewModel.filePath.isEmpty))
             
                .animation(.easeInOut, value: isHoveringRunButton)
            }
            
            // Exit code indicator
            if viewModel.lastExitCodeVisible {
                HStack {
                    Image(systemName: viewModel.lastExitCode == 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(viewModel.lastExitCode == 0 ? .green : .red)
                    
                    Text("Exit Code: \(viewModel.lastExitCode)")
                        .font(.system(.body, design: .monospaced))
                }
                .transition(.opacity)
            }
            
            // Output console
            ZStack {
                TextEditor(text: .constant(viewModel.outputText))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if viewModel.isRunning {
                    ProgressView("Running...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
            .frame(width: 800, height: 600)
    }
}
