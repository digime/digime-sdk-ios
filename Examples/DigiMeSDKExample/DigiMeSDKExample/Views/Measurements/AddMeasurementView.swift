//
//  AddMeasurementView.swift
//  DigiMeSDKExample
//
//  Created on 12/06/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Combine
import DigiMeSDK
import SwiftUI

struct AddMeasurementView: View {
    @AppStorage("selfMeasurementLastUsedType") var measurementType: SelfMeasurementType = .weight
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var viewModel: MeasurementsViewModel

    @State private var creationDate = Date()
    @State private var showTimeOption = true
    @State private var showDatePicker = false
    @State private var showingPersonsList = false
    @State private var showingMeasurementTypeSelection = false
    @State private var showAlert = false
    @State private var inputValue: String = ""
    @State private var inputValueSecondary: String = ""
    @State private var comment: String = ""
    @State private var commentName: String = ""
    @State private var commentCode: String = ""
    @State private var commentTiming: String = ""
    @State private var alert: NotifyBanner?

    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isTextEditorCommentFocused: Bool
    @FocusState private var isTextEditorCommentNameFocused: Bool
    @FocusState private var isTextEditorCommentCodeFocused: Bool
    @FocusState private var isTextEditorCommentTimingFocused: Bool

    @Binding var navigationPath: NavigationPath

    private let numberFormatter = NumberFormatter()
    private var formatter: DateFormatter {
        let fm = DateFormatter()
        fm.dateStyle = .medium
        fm.timeStyle = .none
        return fm
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
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
                            Text(formatter.string(from: creationDate))
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
                                .fill(Color(.secondarySystemBackground))
                        )
                    }

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
                                            Text("What you were doing before and after reading:")
                                                .foregroundColor(Color(.placeholderText))
                                                .padding(.leading, 10)
                                                .padding(.top, 10)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .allowsHitTesting(false)
                                                .background(Color(.clear))
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
                                Text("Name")
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
                                                .background(Color(.clear))
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
                                Text("Code")
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
                                Text("Timing")
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

                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        let number = formatter.number(from: inputValue)
                        let decimalValue = number?.decimalValue ?? 0.0

                        var newComponents: [SelfMeasurementComponent] = []
                        newComponents.append(SelfMeasurementComponent(measurementValue: decimalValue, unit: measurementType.unitValue, unitCode: measurementType.unitCode, display: measurementType.unitDisplayValue))

                        if measurementType == .bloodPressure {
                            let numberSecondary = formatter.number(from: inputValueSecondary)
                            let decimalValueSecondary = numberSecondary?.decimalValue ?? 0.0
                            newComponents.append(SelfMeasurementComponent(measurementValue: decimalValueSecondary, unit: measurementType.unitValueSecondary, unitCode: measurementType.unitCodeSecondary, display: measurementType.unitDisplayValueSecondary))
                        }

                        let newEntry = SelfMeasurement(name: measurementType.description,
                                                       type: measurementType,
                                                       createdDate: creationDate,
                                                       components: newComponents,
                                                       comment: comment.isEmpty ? nil : comment.trimAndReduceSpaces(),
                                                       commentName: commentName.isEmpty ? nil : commentName.trimAndReduceSpaces(),
                                                       commentCode: commentCode.isEmpty ? nil : commentCode.trimAndReduceSpaces(),
                                                       commentTiming: commentTiming.isEmpty ? nil : commentTiming.trimAndReduceSpaces(),
                                                       receipts: []
                        )
                        
                        viewModel.addMeasurement(newEntry)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text("Add")
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
                .navigationBarTitle("Add measurement", displayMode: .inline)
                .padding(20)
            }
            .blur(radius: showDatePicker ? 3 : 0)
            .disabled(showDatePicker)

            if showDatePicker {
                withAnimation(.spring()) {
                    DatePickerWithButtons(showDatePicker: $showDatePicker, showTime: $showTimeOption, date: $creationDate)
                        .shadow(radius: 20)
                        .offset(y: self.showDatePicker ? 0 : UIScreen.main.bounds.height)
                }
            }
        }
        .interactiveDismissDisabled(showDatePicker)
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(-5)
        .onAppear {
            isTextFieldFocused = true
        }
        .bannerView(toast: $alert)
    }

    private func inputIsValid() -> Bool {
        return measurementType != .none && !inputValue.isEmpty
    }
    
    private func notify() {
        alert = NotifyBanner(type: .success, title: "Success", message: "Your new self-measurement has been successfully added!")
    }
}

#Preview {
    let previewer = try? Previewer()
    let mockNavigationPath = NavigationPath()

    return NavigationStack {
        AddMeasurementView(navigationPath: .constant(mockNavigationPath))
            .modelContainer(previewer!.container)
            .environment(\.colorScheme, .dark)
    }
}
