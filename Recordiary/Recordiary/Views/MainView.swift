//
//  MainTabView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI
import UIKit

struct MainView: View {
    // 기본 선택 탭 설정을 위한 State 변수
    @State private var selectedTab = 1  // 마이홈 탭을 기본값으로 설정

    init() {
        // 탭 바 스타일 설정
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.75) // 탭 바 배경색
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        
        // 네비게이션 바 스타일 설정
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.75) // 네비게이션 바 배경색
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor(red: 0x2C / 255.0, green: 0x3E / 255.0, blue: 0x50 / 255.0, alpha: 1)
        ]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // 캘린더 탭
            NavigationView {
                CalendarView()
                    .navigationTitle("캘린더")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "calendar")

            }
            .tag(0)

            // 마이홈 탭 (기본 탭)
            NavigationView {
                MyHomeView()
                    .navigationTitle("마이홈")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "house")
            }
            .tag(1)

            // 소셜 탭
            NavigationView {
                SocialView()
                    .navigationTitle("소셜")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "person.3")
            }
            .tag(2)
        }
        .accentColor(Color(hex: "#6DAFCF")) // 선택된 탭 아이콘 색상 설정
    }
}

