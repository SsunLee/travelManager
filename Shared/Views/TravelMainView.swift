import SwiftUI

struct TravelMainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TravelGroup.startDate, ascending: false)],
        animation: .default)
    private var travelGroups: FetchedResults<TravelGroup>
    
    @State private var showingAddGroup = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(travelGroups) { group in
                    NavigationLink(destination: TravelDetailView(group: group)) {
                        TravelGroupRow(group: group)
                    }
                }
                .onDelete(perform: deleteTravelGroups)
            }
            .navigationTitle("여행의 모든 순간")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGroup.toggle() }) {
                        Label("새 여행", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGroup) {
                TravelAddGroupView()
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
            Text(group.title)
                .font(.headline)
            HStack {
                Text(group.startDate, style: .date)
                Text("-")
                Text(group.endDate, style: .date)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
