//
//  MainTabView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabRoute = .home
    @State private var showCreateSheet = false
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Контент
            Group {
                switch selectedTab {
                case .home:     HomeView().environmentObject(homeViewModel)
                case .settings: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(
                selectedTab: $selectedTab,
                onPlusTap: { showCreateSheet = true }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showCreateSheet) {
            CardManagerView(onDismissToHome: {
                showCreateSheet = false
                selectedTab = .home
            }, onViewCategory: { category in
                showCreateSheet = false
                selectedTab = .home
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    homeViewModel.selectCategory(category)
                }
            })
            .environmentObject(homeViewModel)
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: TabRoute
    let onPlusTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Home tab
            TabBarItem(
                icon: "house.fill",
                label: "Home",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            Spacer()

            // Plus button
            Button(action: onPlusTap) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "5BAECC"), Color(hex: "4A9AB8")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                        .shadow(color: Color(hex: "5BAECC").opacity(0.4), radius: 10, x: 0, y: 4)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -16)

            Spacer()
            
            // Settings tab
            TabBarItem(
                icon: "gearshape.fill",
                label: "Settings",
                isSelected: selectedTab == .settings
            ) {
                selectedTab = .settings
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(Color("AppSurface"))
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Item

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(hex: "5BAECC") : Color("AppTextHint"))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "5BAECC") : Color("AppTextHint"))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Card Sheet (заглушка)

struct CreateCardSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBg").ignoresSafeArea()
                Text("Create card or folder — coming soon")
                    .foregroundColor(Color("AppTextSecondary"))
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "5BAECC"))
                }
            }
        }
    }
}

// MARK: - Tab Routes
enum TabRoute: Hashable {
    case home, settings
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager.shared)
}
