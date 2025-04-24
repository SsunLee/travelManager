import SwiftUI

struct TravelMainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TravelGroup.isPinned, ascending: false),
            NSSortDescriptor(keyPath: \TravelGroup.startDate, ascending: false)
        ],
        animation: .default)
    private var travelGroups: FetchedResults<TravelGroup>
    
    @State private var showingAddGroup = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // Conditionally display List or Empty View
                if travelGroups.isEmpty {
                    VStack(spacing: 10) {
                        Spacer() // Push content to center
                        Image(systemName: "figure.walk.departure") // Example icon
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("여행 일지를 추가해보세요")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer() // Push content to center
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Take full space
                } else {
                    List {
                        ForEach(travelGroups) { group in
                            HStack { 
                                Button {
                                    togglePin(for: group)
                                } label: {
                                    Image(systemName: group.isPinned ? "pin.fill" : "pin")
                                        .foregroundColor(group.isPinned ? .yellow : .gray)
                                }
                                .buttonStyle(.borderless) 
                                
                                NavigationLink(destination: TravelDetailView(group: group)) {
                                    TravelGroupRow(group: group)
                                }
                            }
                        }
                        .onDelete(perform: deleteTravelGroups)
                    }
                    // List modifiers can stay here if needed
                }
                
                // Floating Action Button (FAB) - Remains in ZStack
                Button {
                    showingAddGroup.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color.blue) 
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5, x: 0, y: 5)
                }
                .padding(30) 
                
            } // End ZStack
            .navigationTitle("여행의 모든 순간") // Keep navigation title outside conditional view
            .sheet(isPresented: $showingAddGroup) {
                TravelAddGroupView()
            }
        }
    }
    
    private func togglePin(for group: TravelGroup) {
        withAnimation {
            group.isPinned.toggle()
            do {
                try viewContext.save()
            } catch {
                print("Error saving pin status: \(error)")
                group.isPinned.toggle()
            }
        }
    }
    
    private func deleteTravelGroups(offsets: IndexSet) {
        withAnimation {
            offsets.map { travelGroups[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting travel group: \(error)")
            }
        }
    }
}

struct TravelGroupRow: View {
    let group: TravelGroup
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.title ?? "제목 없음")
                .font(.headline)
            HStack {
                Text(group.startDate ?? Date(), style: .date)
                Text("-")
                Text(group.endDate ?? Date(), style: .date)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
