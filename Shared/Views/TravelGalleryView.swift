import SwiftUI
import PhotosUI

struct TravelGalleryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let group: TravelGroup
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var selectedPhoto: TravelPhoto?
    @State private var showingPhotoDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 2)
                ], spacing: 2) {
                    ForEach(sortedPhotos) { photo in
                        if let imageData = photo.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .onTapGesture {
                                    selectedPhoto = photo
                                    showingPhotoDetail = true
                                }
                        }
                    }
                }
                .padding(2)
            }
            .navigationTitle("갤러리")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: selectedImage) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        addPhoto(imageData: data)
                    }
                }
            }
            .sheet(isPresented: $showingPhotoDetail) {
                if let photo = selectedPhoto {
                    PhotoDetailView(photo: photo)
                }
            }
        }
    }
    
    private var sortedPhotos: [TravelPhoto] {
        let photoSet = group.gallery as? Set<TravelPhoto> ?? []
        return photoSet.sorted { photo1, photo2 in
            guard let date1 = photo1.date else { return false }
            guard let date2 = photo2.date else { return true }
            return date1 > date2
        }
    }
    
    private func addPhoto(imageData: Data) {
        let newPhoto = TravelPhoto(context: viewContext)
        newPhoto.id = UUID()
        newPhoto.imageData = imageData
        newPhoto.date = Date()
        newPhoto.travelGroup = group
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving photo: \(error)")
        }
    }
}

struct PhotoDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let photo: TravelPhoto
    @State private var caption: String
    
    init(photo: TravelPhoto) {
        self.photo = photo
        _caption = State(initialValue: photo.caption ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                photoImageView
                
                TextField("설명", text: $caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .navigationTitle("사진 상세")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveCaption()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var photoImageView: some View {
        if let imageData = photo.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .padding()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding()
                .foregroundColor(.gray)
        }
    }
    
    private func saveCaption() {
        photo.caption = caption.isEmpty ? nil : caption
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving caption: \(error)")
        }
    }
} 