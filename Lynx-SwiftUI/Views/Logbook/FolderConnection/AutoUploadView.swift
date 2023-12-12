//
//  AutoUploadView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/11/23.
//

import SwiftUI

struct AutoUploadView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showAutoUpload: Bool
    
    @State private var progressValue: Double = 0.0
    @State private var randomSlopes: [String] = ["Mountain Slopes", "Snowy Adventure", "Skiing Fun", "Powder Paradise"]
    @State private var slopesFileName: String = ""

    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        backgroundCapsule
            .overlay(
                HStack(alignment: .center, spacing: Constants.hstackSpacing) {
                    Spacer()
                    progress
                    slopeUploadText
                }
            )
            .onReceive(timer) { _ in
                withAnimation {
                    progressValue += 0.1 // Adjust the increment value as needed
                    if progressValue > 1.0 {
                        timer.upstream.connect().cancel()
                        progressValue = 1.0
                        slopesFileName = "All Done! "
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showAutoUpload = false
                        }
                    } else {
                        slopesFileName = randomSlopes.randomElement()!
                    }
                }
            }
    }
    
    // MARK: - Views
    private var backgroundCapsule: some View {
        RoundedRectangle(cornerRadius: Constants.BackgroundCapsule.cornerRadius)
            .frame(
                maxWidth: Constants.BackgroundCapsule.width,
                maxHeight: Constants.BackgroundCapsule.height
            )
            .foregroundStyle(
                Color(uiColor: .tertiarySystemGroupedBackground)
            )
            .shadow(radius: Constants.BackgroundCapsule.shadowRadius)
    }
    
    private var progress: some View {
        HStack {
            if progressValue < 1.0 {
                CircularProgressView(progress: $progressValue)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.lynx)
                    .transition(.scale)
            }
        }
    }
    
    private var slopeUploadText: some View {
        HStack {
            Text(slopesFileName)
                .font(.subheadline)
                .transition(progressValue < 1.0 ? .rollDownInandOut : .rollDownAndIdentity)
                .id(UUID().uuidString + slopesFileName)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Constants For Main View
    private struct Constants {
        static let hstackSpacing: CGFloat = 10
        struct BackgroundCapsule {
            static let cornerRadius: CGFloat = 25.0
            static let width: CGFloat = 300
            static let height: CGFloat = 65
            static let shadowRadius: CGFloat = 5
        }
    }
}

struct CircularProgressView: View {
    @Binding var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: Constants.lineWidth)
                .opacity(Constants.backgroundOpacity)
                .foregroundColor(Color.secondary)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    style: StrokeStyle(lineWidth: Constants.lineWidth,
                    lineCap: .round,
                    lineJoin: .round))
                .foregroundColor(Color.lynx)
                .rotationEffect(Constants.rotationAngle)
        }
        .frame(
            width: Constants.widthHeight,
            height: Constants.widthHeight
        )
        .transition(.identity)
    }
    
    
    private struct Constants {
        static let lineWidth: CGFloat = 5.0
        static let backgroundOpacity: CGFloat = 0.3
        
        static let rotationAngle: Angle = .degrees(270.0)
        static let widthHeight: CGFloat = 25.0
    }
}

// MARK: - Modifiers/Transitions
struct RollDownModifier: ViewModifier {
    let yOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: yOffset)
            .clipped()
    }
}


extension AnyTransition {
    static var rollDownFromTop: AnyTransition {
        .modifier(
            active: RollDownModifier(yOffset: -50),
            identity: RollDownModifier(yOffset: 0)
        )
    }
    
    static var rollDownOut: AnyTransition {
        .modifier(active: RollDownModifier(yOffset: 50),
                   identity: RollDownModifier(yOffset: 0))
        .combined(
            with: .scale
        )
    }
    
    static var rollDownInandOut: AnyTransition {
        .asymmetric(insertion: .rollDownFromTop, removal: .rollDownOut)
    }
    
    static var rollDownAndIdentity: AnyTransition {
        .asymmetric(insertion: .rollDownFromTop, removal: .identity)
    }
}

#Preview {
    AutoUploadView(showAutoUpload: .constant(true))
}
