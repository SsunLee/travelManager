import SwiftUI

struct TravelAddGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Read profile name from AppStorage
    @AppStorage("profileName") var profileName: String = "나"
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    // State for *additional* members added by the user
    @State private var members: [String] = [] 
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
                    // Always display the profile owner (non-deletable)
                    Text(profileName) 
                        .foregroundColor(.secondary) // Indicate it's the owner
                    
                    // List additional members (deletable)
                    ForEach(members, id: \.self) { member in
                        Text(member)
                    }
                    .onDelete(perform: deleteMember) // Only allow deleting additional members
                    
                    // Add new member input
                    HStack {
                        TextField("새 멤버 추가", text: $newMember)
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
    
    // Adds member to the additional members list
    private func addMember() {
        if !newMember.isEmpty && !members.contains(newMember) && newMember != profileName {
            members.append(newMember)
            newMember = ""
        }
        // TODO: Add user feedback if name already exists or is the profile owner
    }
    
    // Deletes from the additional members list
    private func deleteMember(at offsets: IndexSet) {
        members.remove(atOffsets: offsets)
    }
    
    private func saveTravel() {
        let newTravel = TravelGroup(context: viewContext)
        newTravel.id = UUID()
        newTravel.title = title
        newTravel.startDate = startDate
        newTravel.endDate = endDate
        
        // Combine profile owner and additional members for saving
        var finalMembers = [profileName] // Start with profile owner
        finalMembers.append(contentsOf: members.filter { $0 != profileName }) // Add others, ensure no duplicates
        newTravel.members = finalMembers
        
        // Ensure memberAccessToken is generated (if needed, otherwise remove)
        newTravel.memberAccessToken = UUID() 
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving travel: \(error)")
        }
    }
}
