//
//  ContentView.swift
//  Shared
//
//  Created by Sunbae lee on 2022/08/15.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            // First Tab: Home (Existing TravelMainView)
            TravelMainView()
                .tabItem {
                    Label("홈", systemImage: "house")
                }
            
            // Second Tab: Menu (Placeholder)
            MenuView()
                .tabItem {
                    Label("메뉴", systemImage: "list.bullet")
                }
        }
    }
}

// Settings View for the Menu Tab
struct MenuView: View {
    // 0: System, 1: Light, 2: Dark
    @AppStorage("selectedAppearance") var selectedAppearance: Int = 0 
    
    // App Version
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    
    var body: some View {
        NavigationView { 
            Form {
                Section(header: Text("내 프로필")) {
                    NavigationLink(destination: ProfileEditView()) {
                        Text("프로필 수정")
                    }
                }
                
                Section(header: Text("화면 테마 설정")) {
                    Picker("화면 모드", selection: $selectedAppearance) {
                        Text("기기 설정 동일").tag(0)
                        Text("라이트 모드").tag(1)
                        Text("다크 모드").tag(2)
                    }
                    // Optional: Display current selection text if Picker style needs it
                    // Text(currentAppearanceDescription) 
                }
                
                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("앱 버전")
                        Spacer()
                        Text("v\(appVersion) (\(buildVersion))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("메뉴")
        }
    }
    
    // Optional helper to display text for current selection
    /*
    private var currentAppearanceDescription: String {
        switch selectedAppearance {
        case 1: return "라이트 모드"
        case 2: return "다크 모드"
        default: return "기기 설정 동일"
        }
    }
    */
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
