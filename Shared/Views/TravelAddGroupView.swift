import SwiftUI

struct TravelAddGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var members: [String] = ["나"]
    @State private var newMember = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("여행 정보")) {
                    TextField("여행 제목", text: $title)
                    DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                    DatePicker("종료일", selection: $endDate, displayedComponents: .date)
                }
                
                Section(header: Text("여행 멤버")) {
                    ForEach(members, id: \.self) { member in
                        Text(member)
                    }
                    .onDelete(perform: deleteMember)
                    
                    HStack {
                        TextField("새 멤버", text: $newMember)
                        Button(action: addMember) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newMember.isEmpty)
                    }
                }
            }
            .navigationTitle("새 여행")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveTravel()
                    }
                    .disabled(title.isEmpty)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addMember() {
        if !newMember.isEmpty {
            members.append(newMember)
            newMember = ""
        }
    }
    
    private func deleteMember(at offsets: IndexSet) {
        members.remove(atOffsets: offsets)
    }
    
    private func saveTravel() {
        let newTravel = TravelGroup(context: viewContext)
        newTravel.id = UUID()
        newTravel.title = title
        newTravel.startDate = startDate
        newTravel.endDate = endDate
        newTravel.members = members
        newTravel.memberAccessToken = UUID()
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving travel: \(error)")
        }
    }
}
