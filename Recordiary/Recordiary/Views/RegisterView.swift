//
//  RegisterView.swift
//  Recordiary
//
//  Created by 권동민 on 12/8/24.
//


import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isRegistering: Bool = false // 회원가입 처리 중 상태
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Spacer()
                
                // 타이틀
                Text("회원가입")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#6DAFCF"))
                    .padding(.bottom, 24)
                
                // 이름 입력
                TextField("이름", text: $name)
                    .padding()
                    .background(Color(hex: "#F9F9F9"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                    )
                    .autocapitalization(.words)
                    .padding(.horizontal)
                
                // 이메일 입력
                TextField("이메일", text: $email)
                    .padding()
                    .background(Color(hex: "#F9F9F9"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                // 비밀번호 입력
                HStack {
                    if isPasswordVisible {
                        TextField("비밀번호", text: $password)
                            .autocapitalization(.none)
                    } else {
                        SecureField("비밀번호", text: $password)
                            .autocapitalization(.none)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(Color(hex: "#999999"))
                    }
                }
                .padding()
                .background(Color(hex: "#F9F9F9"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // 회원가입 버튼
                Button(action: handleRegister) {
                    if isRegistering {
                        ProgressView() // 처리 중 로딩 표시
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("회원가입")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#6DAFCF"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .disabled(isRegistering || name.isEmpty || email.isEmpty || password.isEmpty) // 입력값 확인
                .padding(.horizontal)
                
                Spacer()
                
                // 로그인 페이지 이동
                NavigationLink(destination: LoginView()) {
                    Text("이미 계정이 있으신가요? 로그인")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#6DAFCF"))
                        .padding(.top, 16)
                }
            }
            .background(Color(hex: "#FFF8E1").ignoresSafeArea())
            .navigationBarTitle("회원가입", displayMode: .inline)
        }
    }
    
    // 회원가입 처리
    private func handleRegister() {
        isRegistering = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2초 대기 후 회원가입 완료 처리
            isRegistering = false
            print("회원가입 완료: \(name), \(email)")
        }
    }
}
