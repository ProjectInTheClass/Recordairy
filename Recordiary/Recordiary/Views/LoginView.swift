//
//  LoginView.swift
//  Recordiary
//
//  Created by 권동민 on 12/8/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email: String = ""

    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea() // 배경 색상

            VStack(spacing: 24) {
                // 제목
                VStack(spacing: 8) {
                    Text("로그인")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#6DAFCF"))
                }
                .padding(.top, 40)

                // 이메일 입력 섹션
                VStack(alignment: .leading, spacing: 16) {
                    Text("이메일")
                        .font(.headline)
                        .foregroundColor(.black)

                    TextField("이메일", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 30)

                // 다음 버튼
                Button(action: {
                    // 다음 버튼 동작
                    print("이메일로 로그인: \(email)")
                }) {
                    Text("다음")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#6DAFCF"))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 30)

                // 또는
                Text("또는")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // 로그인 옵션 버튼
                VStack(spacing: 16) {
                    socialLoginButton(iconName: "bubble.left.fill", text: "카카오로 시작하기", backgroundColor: Color(hex: "#F7E600"))
                    SignInWithAppleButton(.signIn, onRequest: configureRequest, onCompletion: handleAuthorization)
                        .frame(height: 50)
                        .cornerRadius(8)
                        .padding(.horizontal, 30)
                    socialLoginButton(iconName: "n.square.fill", text: "네이버로 시작하기", backgroundColor: Color(hex: "#03C75A"))
                }

                Spacer()

                // 회원가입 버튼
                NavigationLink(destination: RegisterView()) {
                    Text("회원가입")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#6DAFCF"))
                        .underline()
                }
                .padding(.bottom, 8)

                // MyHomeView로 돌아가는 버튼
//                NavigationLink(destination: MyHomeView()) {
//                    Text("홈으로 돌아가기")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color(hex: "#6DAFCF"))
//                        .cornerRadius(8)
//                        .padding(.horizontal, 30)
//                }
//                .padding(.bottom, 24)
            }
        }
    }

    // Apple 로그인 요청 구성
    private func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    // Apple 로그인 결과 처리
    private func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            print("Apple 로그인 성공: \(authResults)")
        case .failure(let error):
            print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    // 소셜 로그인 버튼
    private func socialLoginButton(iconName: String, text: String, backgroundColor: Color) -> some View {
        Button(action: {
            print("\(text) 클릭")
        }) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .padding(.horizontal, 30)
    }
}
