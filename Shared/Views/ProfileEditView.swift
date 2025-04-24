import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @AppStorage("profileName") var profileName: String = "나" // Default value is "나"
    @AppStorage("profileGender") var profileGender: String = "미설정"
    @AppStorage("profileAge") var profileAgeString: String = ""
    
    // State for photo picker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImageData: Data? // Store image data temporarily
    
    var body: some View {
        Form {
            Section(header: Text("프로필 사진")) {
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack {
                            if let profileImageData,
                               let uiImage = UIImage(data: profileImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                // Placeholder Icon
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                            Text("사진 변경")
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            
            Section(header: Text("기본 정보")) {
                TextField("이름", text: $profileName)
                
                Picker("성별", selection: $profileGender) {
                    Text("미설정").tag("미설정")
                    Text("남성").tag("남성")
                    Text("여성").tag("여성")
                }
                
                HStack {
                    Text("나이")
                    TextField("예: 30", text: $profileAgeString)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    profileImageData = data
                    // TODO: Implement saving image data to file system 
                    // and store the file path in AppStorage instead of raw data.
                }
            }
        }
        // TODO: Load profile image data from file system on appear
        // .onAppear { loadImage() }
    }
    
    // TODO: func saveImage() { ... }
    // TODO: func loadImage() { ... }
} 