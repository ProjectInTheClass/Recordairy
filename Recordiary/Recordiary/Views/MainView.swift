//
//  MainTabView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI
import UIKit
/*
struct MainView: View {
    @StateObject private var calendarViewModel = CalendarViewModel()
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
                CalendarView(viewModel: calendarViewModel)
                    .navigationTitle("캘린더")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "calendar")

            }
            .tag(0)

            // 마이홈 탭 (기본 탭)
            NavigationView {
                MyHomeView(calendarViewModel: calendarViewModel)
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
}*/
struct MainView: View {
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var selectedTab = 1  // 기본 탭 설정
    @State private var showLogin = false
    @State private var showRegister = false

    init() {
        // 탭 바와 네비게이션 바 스타일 설정
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor(red: 0x2C / 255.0, green: 0x3E / 255.0, blue: 0x50 / 255.0, alpha: 1)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some View {
        ZStack {
            // TabView
            TabView(selection: $selectedTab) {
                // 캘린더 탭
                NavigationView {
                    CalendarView(viewModel: calendarViewModel)
                        .navigationTitle("캘린더")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Image(systemName: "calendar")
                }
                .tag(0)

                // 마이홈 탭
                NavigationView {
                    MyHomeView(calendarViewModel: calendarViewModel)
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
            .accentColor(Color(hex: "#6DAFCF"))

            // 상단에 버튼 추가
            VStack {
                HStack {
                    Spacer()
                    Button("로그인") {
                        showLogin = true
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: "#6DAFCF"))
                    .cornerRadius(8)
                    .padding(.trailing, 16)

                    Button("회원가입") {
                        showRegister = true
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: "#6DAFCF"))
                    .cornerRadius(8)
                    .padding(.trailing, 16)
                }
                .padding(.top, 40)
                .padding(.horizontal,100)

                Spacer()
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}
