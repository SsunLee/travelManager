import SwiftUI

struct TravelDetailView: View {
    let group: TravelGroup
    @State private var showingAddExpense = false
    @State private var showingAddMemo = false
    @State private var showingGallery = false
    
    var body: some View {
        List {
            Section(header: Text("여행 정보")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.title ?? "제목 없음")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Text(group.startDate ?? Date(), style: .date)
                        Text("-")
                        Text(group.endDate ?? Date(), style: .date)
                    }
                    .foregroundColor(.secondary)
                    
                    Text("참여자: \((group.members ?? []).joined(separator: ", "))")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("지출 내역")) {
                ForEach(sortedPayHistory, id: \.self) { expense in
                    ExpenseRow(expense: expense)
                }
                
                Button(action: { showingAddExpense.toggle() }) {
                    Label("지출 추가", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("메모")) {
                Text(group.memo ?? "메모 없음")
                    .padding(.vertical, 8)
                
                Button(action: { showingAddMemo.toggle() }) {
                    Label("메모 추가", systemImage: "square.and.pencil")
                }
            }
            
            Section(header: Text("갤러리")) {
                Button(action: { showingGallery.toggle() }) {
                    Label("갤러리 보기", systemImage: "photo.on.rectangle")
                }
            }
        }
        .navigationTitle("여행 상세")
        .sheet(isPresented: $showingAddExpense) {
            TravelAddPayView(group: group)
        }
        .sheet(isPresented: $showingAddMemo) {
            TravelAddMemoView(group: group)
        }
        .sheet(isPresented: $showingGallery) {
            TravelGalleryView(group: group)
        }
    }
    
    private var sortedPayHistory: [PayHistory] {
        let set = group.payHistory as? Set<PayHistory> ?? []
        return set.sorted {
            // Handle optional dates for sorting: non-nil dates come first (descending)
            guard let date0 = $0.date else { return false } // nil dates are considered older
            guard let date1 = $1.date else { return true }  // nil dates are considered older
            return date0 > date1
        }
    }
}

struct ExpenseRow: View {
    let expense: PayHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(expense.place ?? "장소 없음") // Provide default value
                    .font(.headline)
                Spacer()
                Text("\(expense.amount)원")
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text(expense.cardOwner ?? "카드주인 없음") // Provide default value
                Text("•")
                Text((expense.participants ?? []).joined(separator: ", ")) // Provide default value and join
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if let memo = expense.memo, !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 
