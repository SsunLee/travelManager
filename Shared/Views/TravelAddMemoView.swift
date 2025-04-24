import SwiftUI

struct TravelAddMemoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let group: TravelGroup
    @State private var memo: String
    
    init(group: TravelGroup) {
        self.group = group
        _memo = State(initialValue: group.memo ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("메모")) {
                    TextEditor(text: $memo)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("메모 작성")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveMemo()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveMemo() {
        group.memo = memo.isEmpty ? nil : memo
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving memo: \(error)")
        }
    }
} 