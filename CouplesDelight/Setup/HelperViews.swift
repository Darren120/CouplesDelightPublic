//
//  HelperViews.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/9/20.
//

import Foundation
import SwiftUI
struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        
        return Path{path in
            
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}
struct CustomGradientBackground : View {
    var body: some View {
        LinearGradient(gradient: .init(colors: [Color.pink,Color.orange,Color.red]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
    }
}
struct AnimatableGradient: AnimatableModifier {
    
    // use as overlay Color.clear.modifier(AnimatableGradient(from: [.green, .blue], to: [.orange], pct: self.animation ? 1 : 0))
    let from: [UIColor]
    let to: [UIColor]
    var pct: CGFloat = 0
    
    var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }
    
    func body(content: Content) -> some View {
        var gColors = [Color]()
        
        for i in 0..<from.count {
            gColors.append(colorMixer(c1: from[i], c2: to[i], pct: pct))
        }
        
        return RoundedRectangle(cornerRadius: 15)
            .fill(LinearGradient(gradient: Gradient(colors: gColors),
                                 startPoint: UnitPoint(x: 0, y: 0),
                                 endPoint: UnitPoint(x: 1, y: 1)))
            .frame(width: 200, height: 200)
    }
    
    // This is a very basic implementation of a color interpolation
    // between two values.
    func colorMixer(c1: UIColor, c2: UIColor, pct: CGFloat) -> Color {
        guard let cc1 = c1.cgColor.components else { return Color(c1) }
        guard let cc2 = c2.cgColor.components else { return Color(c1) }
        
        let r = (cc1[0] + (cc2[0] - cc1[0]) * pct)
        let g = (cc1[1] + (cc2[1] - cc1[1]) * pct)
        let b = (cc1[2] + (cc2[2] - cc1[2]) * pct)

        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
}
struct AnimatableColorText: View {
    let from: UIColor
    let to: UIColor
    let pct: CGFloat
    let text: () -> Text
    
    var body: some View {
        let textView = text()
        
        return textView.foregroundColor(Color.clear)
            .overlay(Color.clear.modifier(AnimatableColorTextModifier(from: from, to: to, pct: pct, text: textView)))
    }
    
    struct AnimatableColorTextModifier: AnimatableModifier {
        let from: UIColor
        let to: UIColor
        var pct: CGFloat
        let text: Text
        
        var animatableData: CGFloat {
            get { pct }
            set { pct = newValue }
        }

        func body(content: Content) -> some View {
            return text.foregroundColor(colorMixer(c1: from, c2: to, pct: pct))
        }
        
        // This is a very basic implementation of a color interpolation
        // between two values.
        func colorMixer(c1: UIColor, c2: UIColor, pct: CGFloat) -> Color {
            guard let cc1 = c1.cgColor.components else { return Color(c1) }
            guard let cc2 = c2.cgColor.components else { return Color(c1) }
            
            let r = (cc1[0] + (cc2[0] - cc1[0]) * pct)
            let g = (cc1[1] + (cc2[1] - cc1[1]) * pct)
            let b = (cc1[2] + (cc2[2] - cc1[2]) * pct)

            return Color(red: Double(r), green: Double(g), blue: Double(b))
        }

    }
}

struct LazyView<Content: View>: View {
let build: () -> Content
init(_ build: @autoclosure @escaping () -> Content) {
    self.build = build
}
var body: Content {
    build()
}
}
struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}


struct TextView: UIViewRepresentable {
    var viewModeltext: String
   

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {

        let myTextView = UITextView()
        myTextView.delegate = context.coordinator

        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
    

        return myTextView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = viewModeltext
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if (textView.text.count + text.count) > 500 {
                return false
            }
            if self.parent.viewModeltext.count > 500 || textView.text.count > 500 {
                return false
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            self.parent.viewModeltext = textView.text
   
        }
    }
}
