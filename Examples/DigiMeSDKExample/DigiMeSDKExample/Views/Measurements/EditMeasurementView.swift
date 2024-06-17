//
//  EditMeasurementView.swift
//  DigiMeSDKExample
//
//  Created on 31/08/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Combine
import DigiMeSDK
import SwiftUI

struct EditMeasurementView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showTimeOption = true
    @State private var showDatePicker = false
    @State private var showingPersonsList = false
    @State private var showingMeasurementTypeSelection = false
    @State private var showAlert = false
    
    @State private var name: String = ""
    @State private var inputValue: String = ""
    @State private var inputValueSecondary: String = ""
    @State private var comment: String = ""
    @State private var commentName: String = ""
    @State private var commentCode: String = ""
    @State private var commentTiming: String = ""
    @State private var measurementType: SelfMeasurementType = .weight
    @State private var createdDate = Date()
    @State private var toast: NotifyBanner?

    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isTextEditorNameFocused: Bool
    @FocusState private var isTextEditorCommentFocused: Bool
    @FocusState private var isTextEditorCommentNameFocused: Bool
    @FocusState private var isTextEditorCommentCodeFocused: Bool
    @FocusState private var isTextEditorCommentTimingFocused: Bool
    
    var navigationPath: NavigationPath
    var measurement: SelfMeasurement

    private var numberFormatter: NumberFormatter {
        let fm = NumberFormatter()
        fm.numberStyle = .decimal
        return fm
    }
    private var formatter: DateFormatter {
        let fm = DateFormatter()
        fm.dateStyle = .medium
        fm.timeStyle = .none
        return fm
    }
    
//    init(navigationPath: NavigationPath, measurement: SelfMeasurement) {
//        self.navigationPath = navigationPath
//        self.measurement = measurement
//    }

    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        
                        VStack {
                            HStack {
                                Text("ID")
                                Spacer()
                            }
                            Text(measurement.id.uuidString.lowercased())
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(5)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.primary)
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )

                        Button {
                            showingMeasurementTypeSelection = true
                        } label: {
                            HStack {
                                Text("Type")
                                Spacer()
                                Text(measurementType.description)
                                    .bold()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(measurementType == .none ? Color.red.opacity(0.2) : Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(measurementType == .none ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .navigationDestination(isPresented: $showingMeasurementTypeSelection) {
                                SelectMeasurementTypeView(selection: $measurementType)
                            }
                        }
                        
                        Button {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Date")
                                Spacer()
                                Text(formatter.string(from: createdDate))
                                    .bold()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        
                        HStack {
                            Text(measurementType.unitDisplayValue)
                            Spacer()
                            TextField("0", text: $inputValue)
                                .onChange(of: inputValue) { _, newValue in
                                    let filtered = newValue.filter { ".,0123456789".contains($0) }
                                    self.inputValue = filtered != newValue ? filtered : newValue
                                }
                                .keyboardType(.decimalPad)
                                .padding(10)
                                .frame(width: 150)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(5)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.primary)
                                .focused($isTextFieldFocused)
                        }
                        .foregroundColor(.primary)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                        
                        if measurementType == .bloodPressure {
                            HStack {
                                Text(measurementType.unitDisplayValueSecondary)
                                Spacer()
                                TextField("0", text: $inputValueSecondary)
                                    .onChange(of: inputValueSecondary) { _, newValue in
                                        let filtered = newValue.filter { ".,0123456789".contains($0) }
                                        self.inputValueSecondary = filtered != newValue ? filtered : newValue
                                    }
                                    .keyboardType(.decimalPad)
                                    .padding(10)
                                    .frame(width: 150)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(5)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.primary)
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.systemGray6))
                            )
                        }

                        VStack {
                            HStack {
                                Text("Measurement Name")
                                Spacer()
                            }
                            TextEditor(text: $name)
                                .transparentScrolling()
                                .padding(10)
                                .frame(minHeight: 100, maxHeight: .infinity)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(5)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary)
                                .focused($isTextEditorNameFocused)
                                .overlay(
                                    VStack {
                                        if name.isEmpty && !isTextEditorNameFocused {
                                            Text("Self Measurement Name")
                                                .foregroundColor(Color(.placeholderText))
                                                .padding(.leading, 10)
                                                .padding(.top, 10)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .allowsHitTesting(false)
                                            Spacer()
                                        }
                                    }
                                )
                        }
                        .foregroundColor(.primary)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                    
                        if measurementType == .heartRate {
                            VStack {
                                HStack {
                                    Text("Comment")
                                    Spacer()
                                }
                                TextEditor(text: $comment)
                                    .transparentScrolling()
                                    .padding(10)
                                    .frame(minHeight: 100, maxHeight: .infinity)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(5)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                    .focused($isTextEditorCommentFocused)
                                    .overlay(
                                        VStack {
                                            if comment.isEmpty && !isTextEditorCommentFocused {
                                                Text("What were you doing before or during the reading")
                                                    .foregroundColor(Color(.placeholderText))
                                                    .padding(.leading, 10)
                                                    .padding(.top, 10)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .allowsHitTesting(false)
                                                Spacer()
                                            }
                                        }
                                    )
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        
                        if measurementType == .bloodGlucose {
                            VStack {
                                HStack {
                                    Text("Comment Name")
                                    Spacer()
                                }
                                TextEditor(text: $commentName)
                                    .transparentScrolling()
                                    .padding(10)
                                    .frame(minHeight: 100, maxHeight: .infinity)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(5)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                    .focused($isTextEditorCommentNameFocused)
                                    .overlay(
                                        VStack {
                                            if commentName.isEmpty && !isTextEditorCommentNameFocused {
                                                Text("Add your input here:")
                                                    .foregroundColor(Color(.placeholderText))
                                                    .padding(.leading, 10)
                                                    .padding(.top, 10)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .allowsHitTesting(false)
                                                Spacer()
                                            }
                                        }
                                    )
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            
                            VStack {
                                HStack {
                                    Text("Comment Code")
                                    Spacer()
                                }
                                TextEditor(text: $commentCode)
                                    .transparentScrolling()
                                    .padding(10)
                                    .frame(minHeight: 100, maxHeight: .infinity)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(5)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                    .focused($isTextEditorCommentCodeFocused)
                                    .overlay(
                                        VStack {
                                            if commentCode.isEmpty && !isTextEditorCommentCodeFocused {
                                                Text("Add your input here:")
                                                    .foregroundColor(Color(.placeholderText))
                                                    .padding(.leading, 10)
                                                    .padding(.top, 10)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .allowsHitTesting(false)
                                                Spacer()
                                            }
                                        }
                                    )
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            
                            VStack {
                                HStack {
                                    Text("Comment Timing")
                                    Spacer()
                                }
                                TextEditor(text: $commentTiming)
                                    .transparentScrolling()
                                    .padding(10)
                                    .frame(minHeight: 100, maxHeight: .infinity)
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(5)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                    .focused($isTextEditorCommentTimingFocused)
                                    .overlay(
                                        VStack {
                                            if commentTiming.isEmpty && !isTextEditorCommentTimingFocused {
                                                Text("Add your input here:")
                                                    .foregroundColor(Color(.placeholderText))
                                                    .padding(.leading, 10)
                                                    .padding(.top, 10)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .allowsHitTesting(false)
                                                Spacer()
                                            }
                                        }
                                    )
                            }
                            .foregroundColor(.primary)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        
                        Button {
                            guard inputIsValid() else {
                                return
                            }
                            
                            isTextFieldFocused.toggle()
                            
                            notify()

                            if
                                measurementType == .bloodPressure,
                                let secondComponent = measurement.components[safe: 1] {
                                
                                secondComponent.measurementValue = numberFormatter.number(from: inputValueSecondary)?.decimalValue ?? 0
                                secondComponent.unit = measurementType.unitValueSecondary
                                secondComponent.unitCode = measurementType.unitCodeSecondary
                                secondComponent.display = measurementType.unitDisplayValueSecondary
                            }

                            if let firstComponent = measurement.components.first {
                                firstComponent.measurementValue = numberFormatter.number(from: inputValue)?.decimalValue ?? 0
                                firstComponent.unit = measurementType.unitValue
                                firstComponent.unitCode = measurementType.unitCode
                                firstComponent.display = measurementType.unitDisplayValue
                            }

                            measurement.name = name
                            measurement.type = measurementType
                            measurement.createdDate = createdDate
                            measurement.comment = comment.isEmpty ? nil : comment.trimAndReduceSpaces()
                            measurement.commentName = commentName.isEmpty ? nil : commentName.trimAndReduceSpaces()
                            measurement.commentCode = commentCode.isEmpty ? nil : commentCode.trimAndReduceSpaces()
                            measurement.commentTiming = commentTiming.isEmpty ? nil : commentTiming.trimAndReduceSpaces()

                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Text("Save")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            }
                            .foregroundColor(.white)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(inputIsValid() ? Color.accentColor : Color(.systemGray4))
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                    .navigationBarTitle("Edit measurement", displayMode: .inline)
                    .navigationBarItems(trailing: cancelButton)
                    .padding(20)
                }
                .disabled(showDatePicker)
            }
            .interactiveDismissDisabled(showDatePicker)
            .navigationViewStyle(StackNavigationViewStyle())
            .blur(radius: showDatePicker ? 3 : 0)
            .padding(-5)
            .onAppear {
                measurementType = measurement.type
                inputValue = "\(measurement.components.first?.measurementValue ?? 0.0)"

                if
                    measurement.components.count > 1 {

                    let secondary = Array(measurement.components)[1]
                    inputValueSecondary = "\(secondary.measurementValue)"
                }
                
                name = measurement.name
                createdDate = measurement.createdDate
                comment = measurement.comment ?? ""
                commentName = measurement.commentName ?? ""
                commentCode = measurement.commentCode ?? ""
                commentTiming = measurement.commentTiming ?? ""
                isTextFieldFocused = true
            }
            .bannerView(toast: $toast)

            if showDatePicker {
                withAnimation(.spring()) {
                    DatePickerWithButtons(showDatePicker: $showDatePicker, showTime: $showTimeOption, date: $createdDate)
                        .shadow(radius: 20)
                        .offset(y: self.showDatePicker ? 0 : UIScreen.main.bounds.height)
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
                .font(.headline)
        }
    }

    private func inputIsValid() -> Bool {
        return measurementType != .none && !inputValue.isEmpty
    }
    
    private func notify() {
        toast = NotifyBanner(type: .success, title: "Success", message: "Your self-measurement entry has been successfully updated!")
    }
}

#Preview {
    let previewer = try? Previewer()
    let mockNavigationPath = NavigationPath()

    return NavigationStack {
        EditMeasurementView(navigationPath: mockNavigationPath, measurement: previewer!.measurement)
            .modelContainer(previewer!.container)
    }
}
