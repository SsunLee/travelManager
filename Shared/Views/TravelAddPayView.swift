import SwiftUI
import PhotosUI

struct TravelAddPayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let group: TravelGroup
    
    @State private var place = ""
    @State private var amount = ""
    @State private var cardOwner = ""
    @State private var selectedParticipants: [String] = []
    @State private var date = Date()
    @State private var memo = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var receiptImage: Data?
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                ExpenseInfoSection(place: $place, amount: $amount, cardOwner: $cardOwner, date: $date, showingDatePicker: $showingDatePicker)
                ParticipantsSection(members: group.members ?? [], selectedParticipants: $selectedParticipants)
                ReceiptSection(selectedImage: $selectedImage, receiptImage: $receiptImage)
                MemoSection(memo: $memo)
            }
            .navigationTitle("지출 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveExpense()
                    }
                    .disabled(place.isEmpty || amount.isEmpty || cardOwner.isEmpty || selectedParticipants.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: selectedImage) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        receiptImage = data
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheetView(selectedDate: $date, isPresented: $showingDatePicker)
            }
        }
    }
    
    private func saveExpense() {
        let newExpense = PayHistory(context: viewContext)
        newExpense.id = UUID()
        newExpense.place = place
        newExpense.amount = Int64(amount) ?? 0
        newExpense.cardOwner = cardOwner
        newExpense.participants = selectedParticipants
        newExpense.date = date
        newExpense.memo = memo.isEmpty ? nil : memo
        newExpense.receiptImage = receiptImage
        newExpense.travelGroup = group
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving expense: \(error)")
        }
    }
}

// MARK: - Subviews for Sections

private struct ExpenseInfoSection: View {
    @Binding var place: String
    @Binding var amount: String
    @Binding var cardOwner: String
    @Binding var date: Date
    @Binding var showingDatePicker: Bool
    
    var body: some View {
        Section(header: Text("지출 정보")) {
            TextField("지출처", text: $place)
            TextField("금액", text: $amount)
                .keyboardType(.numberPad)
            TextField("카드 주인", text: $cardOwner)
            HStack {
                Text("지출일")
                Spacer()
                Text(date, style: .date)
                    .foregroundColor(.accentColor)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingDatePicker = true
            }
        }
    }
}

private struct ParticipantsSection: View {
    let members: [String] // Receive non-optional array
    @Binding var selectedParticipants: [String]
    
    var body: some View {
        Section(header: Text("참여자")) {
            ForEach(members, id: \.self) { member in
                Button(action: {
                    if selectedParticipants.contains(member) {
                        selectedParticipants.removeAll { $0 == member }
                    } else {
                        selectedParticipants.append(member)
                    }
                }) {
                    HStack {
                        Text(member)
                        Spacer()
                        if selectedParticipants.contains(member) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // Ensure the whole row is tappable
                }
                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle in Form
            }
        }
    }
}

private struct ReceiptSection: View {
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var receiptImage: Data?
    
    var body: some View {
        Section(header: Text("영수증")) {
            PhotosPicker(selection: $selectedImage, matching: .images) {
                if let receiptImage = receiptImage,
                   let uiImage = UIImage(data: receiptImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    Label("영수증 사진 추가", systemImage: "photo")
                }
            }
        }
    }
}

private struct MemoSection: View {
    @Binding var memo: String
    
    var body: some View {
        Section(header: Text("메모")) {
            TextEditor(text: $memo)
                .frame(height: 100)
        }
    }
}

// MARK: - Date Picker Sheet View

private struct DatePickerSheetView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView { // Add NavigationView for title and potential buttons
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer() // Pushes the picker to the top
            }
            .navigationTitle("날짜 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        isPresented = false
                    }
                }
            }
            .onChange(of: selectedDate) { oldValue, newValue in
                // Optional: Immediately dismiss when a date is selected
                // Uncomment the line below if you want immediate dismissal without pressing Done
                 isPresented = false
            }
        }
    }
} 