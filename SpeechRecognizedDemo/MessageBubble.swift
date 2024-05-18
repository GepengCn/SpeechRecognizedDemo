//
//  MessageBubble.swift
//  SpeechRecognizedDemo
//
//  Created by 葛鹏 on 2024/5/18.
//

import Foundation
import SwiftUI


struct BubbleShape: Shape {
    
    var radius: CGFloat = 25
    
    var arrow: CGFloat = 25
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        path.move(to: CGPoint(x: radius, y: 0))
        
        path.addLine(to: CGPoint(x: rect.maxX - radius - arrow, y: 0))
        
        path.addArc(center: CGPoint(x: rect.maxX - radius - arrow, y: radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        
        path.addLine(to: CGPoint(x: rect.maxX - arrow, y: rect.midY - arrow/2))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        
        
        path.addLine(to: CGPoint(x: rect.maxX - arrow, y: rect.midY + arrow/2))
        
        
        path.addLine(to: CGPoint(x: rect.maxX - arrow, y: rect.maxY - radius))
        
        path.addArc(center: CGPoint(x: rect.maxX - radius - arrow, y: rect.maxY - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        path.addLine(to: CGPoint(x: radius, y: rect.maxY))
        
        
        path.addArc(center: CGPoint(x: radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: radius))
        
        
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        
        return path
        
    }
    
}


struct MessageBubble: View {
    
    var radius: CGFloat = 25
    
    var arrow: CGFloat = 25
    
    var text: String
    
    var body: some View {
        
        
        Text(text)
            .padding(.trailing, arrow)
            .foregroundStyle(.white)
            .padding()
            .background( BubbleShape(radius: radius, arrow: arrow)
                .fill(.blue))
            .padding()
        
    }
}


#Preview{
    
    MessageBubble(text: """

    “格式”检查器：点按工具栏右侧的 “格式”单选按钮。若要隐藏边栏，请再次点按它。

    此检查器将显示演示文稿中所选任何内容（如文本、形状或图像）的格式控制。

    “动画效果”检查器：点按工具栏右侧的 “动画效果”单选按钮。若要隐藏边栏，请再次点按它。

    此检查器显示用于给幻灯片上的对象添加动画效果和设定幻灯片之间的过渡的控制。

    “文稿”检查器：点按工具栏右侧的 “文稿”单选按钮。若要隐藏边栏，请再次点按它。

    此检查器显示适用于影响整个演示文稿的元素的格式控制，如主题和声音轨道。
""")
    
}
