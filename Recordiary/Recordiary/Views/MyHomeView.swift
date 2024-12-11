//
//  MyHomeView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI

struct MyHomeView: View {
    @StateObject private var myHomeViewModel = MyHomeViewModel()
    @StateObject private var libraryViewModel = LibraryViewModel()
    @StateObject private var storageViewModel = StorageViewModel()
    @ObservedObject var calendarViewModel: CalendarViewModel
    @State private var isLibrarySheetPresented = false
    @State private var isStorageSheetPresented = false

    // 추가된 상태 변수
    @State private var showReaction = false
    @State private var showRectangle = false
    @State private var showSecondRectangle = false
    @State private var isRecordingProcessActive = false
    @State private var selectedFurnitureIndex: Int = 0 //캐러셀 선택시
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea()
            
            RoomView()
                .offset(y: -40)

            // 우측 상단에 수직으로 배치된 버튼들
            VStack(spacing: 16) {
                Button(action: { isLibrarySheetPresented = true }) {
                    Image(systemName: "cart")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21)
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4)
                }
                .disabled(isRecordingProcessActive)
                .sheet(isPresented: $isLibrarySheetPresented) {
                    CustomModal {
                        LibraryModalContent(isPresented: $isLibrarySheetPresented, viewModel: libraryViewModel)
                    }
                }

                Button(action: { isStorageSheetPresented = true }) {
                    Image(systemName: "tray")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21)
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4)
                }
                .disabled(isRecordingProcessActive)
                .sheet(isPresented: $isStorageSheetPresented) {
                    CustomModal {
                        StorageModalContent(isPresented: $isStorageSheetPresented, viewModel: storageViewModel, libraryViewModel: libraryViewModel)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // 중앙 녹음 버튼 및 관련 UI
            VStack {
                Spacer()

                // Reaction 또는 사각형 UI
                if showRectangle {
                    if showSecondRectangle {
                        SecondRectangleView(
                            libraryViewModel: libraryViewModel,
                            selectedFurnitureIndex: $selectedFurnitureIndex,
                            onBack: handleBackButtonTap,
                            onPlacement: handlePlacement,
                            onStore: handleStore
                        )
                    } else {
                        FirstRectangleView(
                            isPlaying: $myHomeViewModel.isPlaying,
                            currentDiary: $myHomeViewModel.currentDiary,
                            onNext: handleNextButtonTap,
                            onPlayPause: myHomeViewModel.playOrPauseRecording
                        )
                    }
                } else if showReaction {
                    Image("radiobutton-reaction")
                        .resizable()
                        .frame(width: 328, height: 114)
                        .offset(y: -25)
                        .transition(.opacity)
                }

                // 녹음 버튼과 취소 버튼
                HStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await handleRadioButtonTap()
                        }
                    }) {
                        Image(buttonImageName)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    .disabled(showRectangle && showSecondRectangle)

                    if isRecordingProcessActive {
                        Button(action: handleCancelTap) {
                            Text("취소")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 80, height: 44)
                                .background(Color(hex: "#FF6F61"))
                                .cornerRadius(12)
                        }
                        .transition(.opacity) // 부드러운 전환
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }

    // 녹음 버튼 이미지 결정
    private var buttonImageName: String {
        if showRectangle && showSecondRectangle {
            return "radiobutton-disabled"
        } else if myHomeViewModel.isRecording {
            return "radiobutton-recording"
        } else {
            return "radiobutton-enabled"
        }
    }

    // 녹음 버튼 동작
    private func handleRadioButtonTap() async {
        withAnimation {
            if showRectangle && !showSecondRectangle {
                showRectangle = false
                showReaction = true
            } else if showReaction {
                showReaction = false
                showRectangle = true
                isRecordingProcessActive = true
            } else {
                showReaction = true
                isRecordingProcessActive = true
            }
        }
        await myHomeViewModel.toggleRecording()
    }

    // "다음" 버튼 동작
    private func handleNextButtonTap() {
        withAnimation {
            showSecondRectangle = true
        }
    }

    // "이전" 버튼 동작
    private func handleBackButtonTap() {
        withAnimation {
            showSecondRectangle = false
        }
    }

    private func handlePlacement(furniture: Furniture) {
        // 가구와 연결된 DiaryConnectedFurniture 생성
        connectDiaryToFurniture(selectedFurniture: furniture, isSet: true)

        resetState()
    }


    private func handleStore(furniture: Furniture) {
        // 보관 동작: is_set = false, 보관함에 추가
        connectDiaryToFurniture(selectedFurniture: furniture, isSet: false)

        resetState() // 초기화
    }

    // 취소 버튼 동작
    private func handleCancelTap() {
        resetState()
    }
    
    private func connectDiaryToFurniture(selectedFurniture: Furniture, isSet: Bool) {
        guard var diary = myHomeViewModel.currentDiary else {
            print("Error: currentDiary is nil.")
            return
        }

        diary.connectedFurniture = selectedFurniture
        calendarViewModel.addDiaryEntry(diary) // 캘린더 모델 업데이트

        if libraryViewModel.decreaseFurnitureQuantity(for: selectedFurniture) {
            if isSet {
                print("Furniture \(selectedFurniture.display_name) is placed.")
            } else {
                storageViewModel.addItem(createDiaryConnectedFurniture(furniture: selectedFurniture, isSet: isSet))
            }
        } else {
            print("Error: Unable to decrease furniture quantity. Check inventory.")
        }
    }
    
    private func createDiaryConnectedFurniture(furniture: Furniture, isSet: Bool) -> DiaryConnectedFurniture {
        guard let diary = myHomeViewModel.currentDiary else {
            fatalError("Diary cannot be nil when creating a connected furniture entry.")
        }

        return DiaryConnectedFurniture(
            furniture: furniture,
            diary: diary,
            created_at: Date(),
            is_set: isSet,
            is_vaild: true,
            position: nil,
            direction: nil
        )
    }

    // 초기화 함수
    private func resetState() {
        withAnimation {
            showReaction = false
            showRectangle = false
            showSecondRectangle = false
            isRecordingProcessActive = false
            myHomeViewModel.isPlaying = false
        }
        myHomeViewModel.isRecording = false
    }
}

struct LibraryModalContent: View {
    @Binding var isPresented: Bool // 모달 상태 바인딩
    @ObservedObject var viewModel: LibraryViewModel // ViewModel 참조
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // 한 줄에 두 개의 아이템

    var body: some View {
        VStack(spacing: 16) {
            // 검색창과 닫기 버튼
            HStack {
                // 닫기 버튼
                Button(action: {
                    isPresented = false // 모달 닫기
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 44, height: 44) // 닫기 버튼 크기
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                // 검색창
                TextField("검색어를 입력하세요", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)
            }
            .padding(.horizontal)

            // 필터 버튼
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.filterMode = .all
                }) {
                    Text("전체")
                        .font(.headline)
                        .foregroundColor(viewModel.filterMode == .all ? .white : .black)
                        .frame(width: 70, height: 35)
                        .background(viewModel.filterMode == .all ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0"))
                        .cornerRadius(8)
                }

                Button(action: {
                    viewModel.filterMode = .unowned
                }) {
                    Text("미보유")
                        .font(.headline)
                        .foregroundColor(viewModel.filterMode == .unowned ? .white : .black)
                        .frame(width: 70, height: 35)
                        .background(viewModel.filterMode == .unowned ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0"))
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.horizontal)

            // 가구 정보 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredItems, id: \.id) { item in
                        VStack(alignment: .leading, spacing: 8) { // 왼쪽 정렬
                            // 가구 이미지
                            Rectangle()
                                .fill(.white)
                                .frame(height: 108)
                                .overlay(
                                    Image(systemName: "photo") // 기본 이미지는 SF Symbol로 대체
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(hex: "#E0E0E0"))
                                        .padding(16)
                                )
                            
                            // 가구 이름
                            Text(item.display_name)
                                .font(.system(size: 16, weight: .bold)) // 볼드
                                .foregroundColor(viewModel.isOwned(item: item) ? .white : .black)

                            // 보유 수량
                            if viewModel.isOwned(item: item) {
                                Text("보유: \(item.quantity)")
                                    .font(.system(size: 14, weight: .semibold)) // 세미볼드
                                    .foregroundColor(.white)
                            } else {
                                Text("미보유")
                                    .font(.system(size: 14, weight: .semibold)) // 세미볼드
                                    .foregroundColor(.black)
                            }
                        }
                        .padding() // 내부 여백
                        .background(
                            viewModel.isOwned(item: item) ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0")
                        )
                        .cornerRadius(21)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
                    }
                }
                .padding()
            }
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 모달 배경색
        .presentationDetents([.medium, .large]) // 중형 & 대형 디텐트 설정
        .presentationDragIndicator(.hidden) // 기본 드래그 인디케이터 숨기기
    }
}

struct StorageModalContent: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: StorageViewModel
    @ObservedObject var libraryViewModel: LibraryViewModel
    @State private var showAlert = false
    @State private var itemToDelete: DiaryConnectedFurniture?

    var body: some View {
        VStack(spacing: 16) {
            // 상단 버튼
            HStack {
                if !viewModel.showDetails {
                    Button(action: {
                        isPresented = false
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#E0E0E0"))
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)

            // 콘텐츠
            if viewModel.showDetails, let furniture = viewModel.selectedFurniture {
                StorageFurnitureDetailView(
                    furniture: furniture,
                    onBack: { viewModel.backToList() }
                )
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.items) { item in
                            HStack(spacing: 16) {
                                Button(action: {
                                    viewModel.selectFurniture(item)
                                }) {
                                    HStack(spacing: 16) {
                                        RoundedRectangle(cornerRadius: 21)
                                            .fill(Color(hex: "#E0E0E0"))
                                            .frame(width: 56, height: 56)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.gray)
                                                    .padding(8)
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.furniture.display_name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.black)
                                            Text(item.diary.local_date)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()
                                    }
                                }

                                // 추가 및 삭제 버튼
                                HStack(spacing: 8) {
                                    Button(action: {
                                        itemToDelete = item
                                        viewModel.updateIsSetToTrue(item)
                                        itemToDelete = nil
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 21)
                                                .fill(Color(hex: "#6DAFCF"))
                                                .frame(width: 56, height: 56)
                                            Image(systemName: "plus")
                                                .font(.system(size: 32))
                                                .foregroundColor(.white)
                                        }
                                    }

                                    Button(action: {
                                        itemToDelete = item
                                        showAlert = true
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 21)
                                                .fill(Color(hex: "#FF6F61"))
                                                .frame(width: 56, height: 56)
                                            Image(systemName: "trash")
                                                .font(.system(size: 32))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(21)
                            .frame(height: 88)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("\(itemToDelete?.furniture.display_name ?? "가구")를 삭제하시겠습니까?"),
                message: Text("삭제된 가구는 라이브러리에 추가됩니다."),
                primaryButton: .destructive(Text("삭제"), action: {
                    if let item = itemToDelete {
                        libraryViewModel.increaseFurnitureQuantity(for: item.furniture) // 수량 증가
                        viewModel.deleteItem(item) // 삭제
                        itemToDelete = nil // 초기화
                    }
                }),
                secondaryButton: .cancel(Text("취소"), action: {
                    itemToDelete = nil // 초기화
                })
            )
        }
    }
}



struct StorageFurnitureDetailView: View {
    let furniture: DiaryConnectedFurniture // 가구 정보
    let onBack: () -> Void   // 뒤로가기 동작

    var body: some View {
        VStack(spacing: 16) {
            // 상단 헤더: 이전 버튼
            HStack {
                Button(action: {
                    onBack() // 리스트로 돌아가기
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#999999")) // 화살표 색
                        Text("이전")
                            .font(.system(size: 20, weight: .semibold)) // 글씨 크기 및 스타일
                            .foregroundColor(Color(hex: "#999999"))
                    }
                }
                Spacer()
            }
            .padding(.horizontal)

            // 상세 정보 콘텐츠
            FurnitureDetailContent(detailedFurniture: furniture)

            Spacer() // 하단 여백 추가로 상단 고정
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // 상단 정렬
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 배경 설정
    }
}
