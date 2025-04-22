import Foundation
import CoreData

class TravelGroup: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var members: [String]
    @NSManaged public var memo: String?
    @NSManaged public var memberAccessToken: UUID
    
    // Relationships will be defined in Core Data model
    @NSManaged public var payHistory: Set<PayHistory>
    @NSManaged public var gallery: Set<TravelPhoto>
}

class PayHistory: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var place: String
    @NSManaged public var amount: Int64
    @NSManaged public var cardOwner: String
    @NSManaged public var participants: [String]
    @NSManaged public var date: Date
    @NSManaged public var receiptImage: Data?
    @NSManaged public var memo: String?
    @NSManaged public var travelGroup: TravelGroup
}

class TravelPhoto: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var imageData: Data
    @NSManaged public var caption: String?
    @NSManaged public var date: Date
    @NSManaged public var travelGroup: TravelGroup
}
