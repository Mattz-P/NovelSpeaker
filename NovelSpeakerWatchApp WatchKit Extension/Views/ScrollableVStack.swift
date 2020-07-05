//
//  ScrollableVStack.swift
//  NovelSpeakerWatchApp WatchKit Extension
//
//  Created by 飯村卓司 on 2020/03/09.
//  Copyright © 2020 IIMURA Takuji. All rights reserved.
//

import SwiftUI

class ScrollableVStackData_old<Content:Hashable>:ObservableObject, Identifiable{
    class ColumnData: Hashable,Identifiable,Equatable {
        let data:Content
        var size:CGSize = .zero
        
        init(data:Content) { self.data = data }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(data)
        }
        static func ==(lhs:ColumnData, rhs:ColumnData) -> Bool {
            lhs.data == rhs.data
        }
    }

    @Published var contentArray:[ColumnData] = [] 
    @Published var scrollOffset:CGFloat = .zero {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var dragHeight:CGFloat = .zero
    @Published var toplevelSize:CGSize = .zero
}

struct ScrollableVStackInnerView_old<Content:Hashable>: View {
    let converter:((Content, ScrollableVStack_old<Content>) -> AnyView)
    let parent:ScrollableVStack_old<Content>
    @ObservedObject var data:ScrollableVStackData_old<Content>
    init(data:ScrollableVStackData_old<Content>, converter:@escaping (Content, ScrollableVStack_old<Content>) -> AnyView, parent: ScrollableVStack_old<Content>) {
        self.data = data
        self.converter = converter
        self.parent = parent
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(self.data.contentArray.indices) { i -> AnyView in
                let content = self.data.contentArray[i] as ScrollableVStackData_old<Content>.ColumnData
                return AnyView(
                    self.converter(content.data, self.parent)
                    .background(GeometryReader { innerViewGeometry in
                    Text("")
                    .onAppear {
                        content.size = innerViewGeometry.size
                    }
                }))
            }
        }
        //.frame(width: nil, height: self.data.contentArray.reduce(0, { $0 + $1.size.height }), alignment: .leading)
    }
}

class ScrollableVStackData<Content:Hashable>:ObservableObject {
    @Published var dataArray:[Content]
    @Published var contentSizeMap:[Int:CGSize] = [:]
    @Published var scrollOffset:CGFloat = .zero {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var dragHeight:CGFloat = .zero
    @Published var toplevelSize:CGSize = .zero
    
    init(dataArray:[Content]) {
        self.dataArray = dataArray
    }
}

struct ScrollableVStackInnerView<Content:Hashable>: View {
    @ObservedObject var data:ScrollableVStackData<Content>
    let converter:((Content, ScrollableVStack<Content>)->AnyView)
    let parent:ScrollableVStack<Content>

    init(data:ScrollableVStackData<Content>, converter:@escaping ((Content, ScrollableVStack<Content>)->AnyView), parent: ScrollableVStack<Content>) {
        self.data = data
        self.converter = converter
        self.parent = parent
        //print("ScrollableVStackData data.dataArray.count: \(data.dataArray.count)")
    }

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(self.data.dataArray, id: \.self, content: { content -> AnyView in
                return AnyView(
                    self.converter(content, self.parent)
                    .onDisappear(perform: {
                        print("onDisappear(\(content.hashValue))")
                        self.data.contentSizeMap.removeValue(forKey: content.hashValue)
                    })
                    .background(
                        GeometryReader { innerViewGeometry in
                            Text("")
                            .onAppear {
                                print("onAppear(\(content.hashValue))")
                                self.data.contentSizeMap[content.hashValue] = innerViewGeometry.size
                            }
                        }
                    )
                )
            })
        }
    }
}

struct ScrollableVStack<Content:Hashable>: View {
    let converter:((Content, ScrollableVStack<Content>)->AnyView)

    @ObservedObject var data:ScrollableVStackData<Content>
    @State var scrollAmount:Float = 0.0 {
        didSet {
            print("scrollAmount changed: \(self.scrollAmount)")
        }
    }

    init(data:[Content], converter:@escaping ((Content, ScrollableVStack<Content>)->AnyView)) {
        self.data = ScrollableVStackData<Content>(dataArray: data)
        self.converter = converter
        print("ScrollableVStack.init() called.")
    }
    
    func UpdateData(data:[Content]) {
        print("ScrollableVStack.UpdateData() data.count: \(data.count)")
        self.data.dataArray = data
    }

    func ScrollToIndex(at:Int, isAnimationEnable:Bool = false){
        var yOffset:CGFloat = 0.0
        for (i,content) in data.dataArray.enumerated() {
            if i == at {
                break
            }
            if let size = data.contentSizeMap[content.hashValue] {
                yOffset += size.height
            }
        }
        scrollTo(height: -yOffset, isAnimationEnable: isAnimationEnable)
    }
    func GetCurrentDisplayedIndex() -> Int? {
        var yOffset:CGFloat = 0.0
        for (i,content) in data.dataArray.enumerated() {
            guard let size = data.contentSizeMap[content.hashValue] else { continue }
            yOffset += size.height
            if yOffset > data.scrollOffset {
                return i
            }
        }
        return nil
    }
    func GetCurrentDisplayedContent() -> Content? {
        guard let index = GetCurrentDisplayedIndex() else { return nil }
        guard data.dataArray.count > index else { return nil }
        return data.dataArray[index]
    }
    
    func CalcTotalContentHeight() -> CGFloat {
        var height:CGFloat = .zero
        for content in data.dataArray {
            guard let size = data.contentSizeMap[content.hashValue] else { continue }
            height += size.height
        }
        return height
    }

    func scrollTo(height:CGFloat, isAnimationEnable:Bool = false) {
        let displayHeight = self.data.toplevelSize.height
        let contentHeight = CalcTotalContentHeight()
        let scrollPositionMin = -(contentHeight - (contentHeight < displayHeight ? 0 : displayHeight))
        print("scrollTo(): height: \(height), displayHeight: \(displayHeight), scrollOffset: \(data.scrollOffset), dragHeight: \(data.dragHeight), contentHeight: \(contentHeight), scrollPositionMin: \(scrollPositionMin)")
        let newScrollOffset:CGFloat
        if height < scrollPositionMin {
            newScrollOffset = scrollPositionMin
        }else if height > 0 {
            newScrollOffset = .zero
        }else{
            newScrollOffset = height
        }

        if isAnimationEnable {
            withAnimation {
                self.data.dragHeight = .zero
                self.data.scrollOffset = newScrollOffset
            }
        }else{
            self.data.dragHeight = .zero
            self.data.scrollOffset = newScrollOffset
        }
    }
    
    func onDragEnded(value:DragGesture.Value) {
        //print("onDragEnded: value: \(value), outerGeometry: \(outerGeometry)")
        scrollTo(height: self.data.scrollOffset + value.predictedEndTranslation.height, isAnimationEnable: true)
    }
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ScrollableVStackInnerView<Content>(data: self.data, converter: self.converter, parent: self)
            }
            .content.offset(x: 0, y: self.data.scrollOffset + self.data.dragHeight + self.CalcTotalContentHeight() / 2 - geometry.size.height / 2)
            .onAppear(perform: {
                self.data.toplevelSize = geometry.size
            })
            .gesture(DragGesture()
                .onChanged({ self.data.dragHeight = $0.translation.height })
                .onEnded({ self.onDragEnded(value: $0) })
            )
            .focusable(true)
            .digitalCrownRotation(self.$scrollAmount, from: 0.0, through: 1.0, by: 0.01, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: false)
        }
    }
}

struct ScrollableVStack_old<Content:Hashable>: View {
    let converter:((Content, ScrollableVStack_old<Content>) -> AnyView)
    
    @ObservedObject var data = ScrollableVStackData_old<Content>()
    
    init(converter:@escaping (Content, ScrollableVStack_old<Content>) -> AnyView) {
        self.converter = converter
    }
    
    func AddContent(content:Content) {
        data.contentArray.append(ScrollableVStackData_old<Content>.ColumnData(data: content))
    }
    func InsertContent(content:Content, at: Int) {
        data.contentArray.insert(ScrollableVStackData_old<Content>.ColumnData(data: content), at: at)
    }
    func RemoveContent(content:Content) {
        data.contentArray.removeAll { $0.data == content }
    }
    func RemoveFromIndex(at:Int){
        data.contentArray.remove(at: at)
    }
    func ScrollToIndex(at:Int, isAnimationEnable:Bool = false){
        var yOffset:CGFloat = 0.0
        for (i,v) in data.contentArray.enumerated() {
            if i == at {
                break
            }
            yOffset += v.size.height
        }
        scrollTo(height: -yOffset, isAnimationEnable: isAnimationEnable)
    }
    func GetCurrentDisplayedIndex() -> Int? {
        var yOffset:CGFloat = 0.0
        for (i,v) in data.contentArray.enumerated() {
            yOffset += v.size.height
            if yOffset > data.scrollOffset {
                return i
            }
        }
        return nil
    }
    func GetCurrentDisplayedContent() -> Content? {
        var yOffset:CGFloat = 0.0
        for v in data.contentArray {
            yOffset += v.size.height
            if yOffset > data.scrollOffset {
                return v.data
            }
        }
        return nil
    }
    
    func scrollTo(height:CGFloat, isAnimationEnable:Bool = false) {
        let displayHeight = self.data.toplevelSize.height
        let contentHeight = self.data.contentArray.reduce(0, { $0 + $1.size.height })
        let scrollPositionMin = -(contentHeight - (contentHeight < displayHeight ? 0 : displayHeight))
        //print("scrollTo(): height: \(height), displayHeight: \(displayHeight), scrollOffset: \(data.scrollOffset), dragHeight: \(data.dragHeight), contentHeight: \(contentHeight), scrollPositionMin: \(scrollPositionMin)")
        let newScrollOffset:CGFloat
        if height < scrollPositionMin {
            newScrollOffset = scrollPositionMin
        }else if height > 0 {
            newScrollOffset = .zero
        }else{
            newScrollOffset = height
        }

        if isAnimationEnable {
            withAnimation {
                self.data.dragHeight = .zero
                self.data.scrollOffset = newScrollOffset
            }
        }else{
            self.data.dragHeight = .zero
            self.data.scrollOffset = newScrollOffset
        }
    }
    
    func onDragEnded(value:DragGesture.Value) {
        //print("onDragEnded: value: \(value), outerGeometry: \(outerGeometry)")
        scrollTo(height: self.data.scrollOffset + value.predictedEndTranslation.height, isAnimationEnable: true)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ScrollableVStackInnerView_old<Content>(data: self.data, converter: self.converter, parent: self)
            }
            .content.offset(x: 0, y: self.data.scrollOffset + self.data.dragHeight + self.data.contentArray.reduce(0, { $0 + $1.size.height }) / 2 - geometry.size.height / 2)
            .onAppear(perform: {
                self.data.toplevelSize = geometry.size
            })
            .gesture(DragGesture()
                .onChanged({ self.data.dragHeight = $0.translation.height })
                .onEnded({ self.onDragEnded(value: $0) })
            )
        }
    }
}

struct ScrollableVStack_Previews: PreviewProvider {
    static var previews: some View {
        let data:[String] = ["あいうえお", "かきくけこ", "さしすせそ"]
        let view = ScrollableVStack<String>(data: data, converter: { content, _ -> AnyView in
            AnyView(Text(content))
        })
        return view
    }
}