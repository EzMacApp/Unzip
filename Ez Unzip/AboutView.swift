//
//  AboutView.swift
//  Ez Unzip
//
//  Created by kkxx on 2024/12/4.
//

import SwiftUI

struct AboutView: View {
    let libraries: [(name: String, url: String)] = [
        ("KeyboardShortcuts", "https://github.com/sindresorhus/KeyboardShortcuts"),
        ("LaunchAtLogin", "https://github.com/sindresorhus/LaunchAtLogin"),
        ("SWCompress", "https://github.com/tsolomko/SWCompression"),
        ("ZipFoundation", "https://github.com/weichsel/ZIPFoundation"),
        ("UnrarKit", "https://github.com/abbeycode/UnrarKit"),
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 40) {
                //  Icon
                ZStack {
                    Image("icon-256")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(color.BaseColor)
                                .modifier(NeumorphismModifier())
                        )
                        .padding(.top, 20)
                }
                .frame(width: 100, height: 100)

                // 版本信息
                VStack(alignment: .center) {
                    Text("Ez Unzip")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    Text("Version \(String(describing: "1.0.0")) (Build \(String(describing: 1)))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.bottom, 20)

            Divider()

            HStack(alignment: .center, spacing: 40) {
                Image("Github")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding(.bottom, 5)

                VStack(alignment: .leading) {
                    ForEach(Array(libraries.enumerated()), id: \.element.name) { index, library in
                        Button(action: {
                            if let url = URL(string: library.url) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Text("\(index + 1). \(library.name)")
                        }.buttonStyle(.link)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 15)

            Divider()

            HStack(alignment: .bottom, spacing: 30) {
                Button(action: {
                    if let url = URL(string: "mailto:ezmacapp@gmail.com") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "envelope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    shareContent()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    if let url = URL(string: "https://www.termsfeed.com/live/a72bbb32-2f56-49ea-9c00-24c2d0d702d6") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Image(systemName: "info.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.blue)
                        .fontWeight(.light)

                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 310, height: 380)
        .padding([.leading, .trailing], 30)
    }
    
    func shareContent() {
           let content = "Hello, check this out!"
           let items: [Any] = [content]
           let picker = NSSharingServicePicker(items: items)
           if let window = NSApplication.shared.keyWindow {
               picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
           }
       }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

struct NeumorphismView: View {
    var body: some View {
        ZStack {
            color.BaseColor
                .edgesIgnoringSafeArea(.all)
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 150, height: 150)
                .modifier(NeumorphismModifier())
        }
    }
}

struct NeumorphismModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(color.ForegroundColor)
            .shadow(color: color.LightShadowColor, radius: 10.0, x: 5.0, y: 5.0)
            .shadow(color: color.DarkShadowColor, radius: 10.0, x: -5.0, y: -5.0)
    }
}

class color {
    static let BaseColor: Color = Color(red: 0.6218541860580444, green: 0.6247249245643616, blue: 0.6333371996879578)
    static let LightShadowColor: Color = Color(red: 0.5434228181838989, green: 0.5462935566902161, blue: 0.554905891418457)
    static let DarkShadowColor: Color = Color(red: 0.7002856135368347, green: 0.7031562924385071, blue: 0.7117685675621033)
    static let ForegroundColor: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0.6610698723325542, green: 0.6639406108388713, blue: 0.6725528859624675), Color(red: 0.5826384997835347, green: 0.5855092382898518, blue: 0.594121513413448)]), startPoint: .topLeading, endPoint: .bottomTrailing)
}
