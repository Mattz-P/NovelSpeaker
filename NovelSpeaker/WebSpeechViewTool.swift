//
//  WebSpeechView.swift
//  NovelSpeaker
//
//  Created by 飯村卓司 on 2021/05/17.
//  Copyright © 2021 飯村卓司. All rights reserved.
//
// WKWebView 上に指定された文字列またはHTMLを表示しつつ、
// 読み上げ箇所更新イベントを受け取るとその読み上げ位置を表示する
//

/*
 TODO:
 - 横書きの時に読み上げ位置の自動スクロールがうまくいかない
 - 読み上げ位置の表示のための選択範囲表示がされていない場合に表示されない問題
 - 読み上げ位置がズレる問題
   - 上記の問題に関連して選択範囲から取得される読み上げ位置がズレているかもしれない
 - 読み替え辞書に登録のみにする、や、読み替え辞書に登録するが追加されていない
 
 正しいJavaScriptの注入方法ぽいのとか、JavaScript側のイベントハンドラをObjective-c側で受ける方法が書いてある
 https://stackoverflow.com/questions/50846404/how-do-i-get-the-selected-text-from-a-wkwebview-from-objective-c
 */

import UIKit
import WebKit

extension UIColor {
    var cssColor:String? {
        get {
            var red:CGFloat = 0
            var green:CGFloat = 0
            var blue:CGFloat = 0
            var alpha:CGFloat = 0
            if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
               , !red.isInfinite, !red.isNaN
               , !green.isInfinite, !green.isNaN
               , !blue.isInfinite, !blue.isNaN
               , !alpha.isInfinite, !alpha.isNaN
            {
                return "rgba(\(String(format: "%d", Int(red*255))), \(String(format: "%d", Int(green*255))), \(String(format: "%d", Int(blue*255))), \(alpha))"
            }
            return nil
        }
    }
}


class WebSpeechViewTool: NSObject, WKNavigationDelegate {
    var wkWebView:WKWebView? = nil
    var loadCompletionHandler:(() -> Void)? = nil
    var siteInfoArray:[StorySiteInfo] = []
    
    func removeDelegate(){
        if let webView = self.wkWebView {
            webView.navigationDelegate = nil;
        }
    }
    
    public func applyFromHtmlString(webView:WKWebView, html:String, baseURL: URL?, siteInfoArray:[StorySiteInfo] = [], completionHandler:(() -> Void)?){
        removeDelegate()
        loadCompletionHandler = completionHandler
        self.wkWebView = webView
        self.siteInfoArray = siteInfoArray
        webView.navigationDelegate = self
        webView.loadHTMLString(html, baseURL: baseURL)
    }
    
    public func applyFromNovelSpeakerString(webView:WKWebView, content: String, foregroundColor: UIColor, backgroundColor: UIColor, displaySetting: RealmDisplaySetting?, baseURL: URL?, siteInfoArray:[StorySiteInfo] = [], completionHandler:(() -> Void)?){
        let html = createContentHTML(content: content, foregroundColor: foregroundColor, backgroundColor: backgroundColor, displaySetting: displaySetting)
        applyFromHtmlString(webView: webView, html: html, baseURL: baseURL, completionHandler: completionHandler)
    }
    
    public func loadUrl(webView:WKWebView, request:URLRequest, siteInfoArray:[StorySiteInfo] = [], completionHandler:(() -> Void)?){
        removeDelegate()
        loadCompletionHandler = completionHandler
        self.wkWebView = webView
        self.siteInfoArray = siteInfoArray
        webView.navigationDelegate = self
        webView.load(request)
    }
    
    func loadInjectScript() -> String? {
        guard let path = Bundle.main.path(forResource: "WebSpeechViewTool_Inject", ofType: "js") else { return nil }
        return try? String.init(contentsOfFile: path)
    }
    
    // WKWebView の読み込み完了ハンドラ
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.canBecomeFirstResponder {
            print("can become first responder")
            webView.becomeFirstResponder()
            webView.window?.makeKeyAndVisible()
        }else{
            print("can NOT become first responder")
        }
        let siteInfoJSONString:String
        if self.siteInfoArray.count > 0 {
            siteInfoJSONString = "[\(self.siteInfoArray.map({$0.generatePageElementOnlySiteInfoString()}).joined(separator: ","))]"
        }else{
            siteInfoJSONString = ""
        }
        let jsFunctions = loadInjectScript() ?? "";
        let jsString = jsFunctions.replacingOccurrences(of: "var elementArray = CreateElementArray();", with: "var elementArray = CreateElementArray(\(siteInfoJSONString));")
        // JavaScript関数群を色々注入しておく
        evaluateJsToString(jsString: jsString) { (result) in
            if let completionHandler = self.loadCompletionHandler {
                completionHandler()
            }
        }
    }
    
    func evaluateJsToString(jsString:String, completionHandler:((String?) -> Void)?){
        guard let wkWebView = self.wkWebView else {
            return
        }
        wkWebView.evaluateJavaScript(jsString) { (node, err) in
            var result:String? = nil;
            defer {
                if let completionHandler = completionHandler {
                    completionHandler(result)
                }
            }
            if let err = err {
                print("js err:", err.localizedDescription)
                print(jsString)
                return
            }
            guard let nodeString = node as? String else {
                print("js node == nil")
                return
            }
            result = nodeString
        }
    }
    func evaluateJsToDouble(jsString:String, completionHandler:((Double?) -> Void)?){
        guard let wkWebView = self.wkWebView else {
            return
        }
        wkWebView.evaluateJavaScript(jsString) { (node, err) in
            var result:Double? = nil;
            defer {
                if let completionHandler = completionHandler {
                    completionHandler(result)
                }
            }
            if let err = err {
                print("js err:", err.localizedDescription)
                print(jsString)
                return
            }
            guard let resultDouble = node as? Double else {
                print("js node == nil")
                return
            }
            result = resultDouble
        }
    }
    func evaluateJsToStringDoubleDictionary(jsString:String, completionHandler:(([String:Double]?) -> Void)?){
        guard let wkWebView = self.wkWebView else {
            return
        }
        wkWebView.evaluateJavaScript(jsString) { (node, err) in
            var result:[String:Double]? = nil;
            defer {
                completionHandler?(result)
            }
            if let err = err {
                print("js err:", err.localizedDescription)
                print(jsString)
                return
            }
            guard let resultDouble = node as? [String:Double] else {
                print("js node == nil")
                return
            }
            result = resultDouble
        }
    }

    
    func assignCSS(cssString:String){
        let oneLineCssString = cssString.replacingOccurrences(of: "\n|\r\n", with: "", options: .regularExpression, range: nil)
        let js = "var styleNode = document.createElement('style');styleNode.innerHTML = \"\(oneLineCssString)\";document.head.appendChild(styleNode); 'OK';"
        evaluateJsToString(jsString: js, completionHandler: nil)
    }
    
    func injectJS(jsString:String) {
        evaluateJsToString(jsString: jsString, completionHandler: nil)
    }
    
    func getSpeechText(completionHandler:((String?) -> Void)?) {
        evaluateJsToString(jsString: "GenerateWholeText(elementArray,0);", completionHandler: completionHandler)
    }
    func highlightSpeechLocation(location:Int, length:Int, scrollRatio: Double) {
        //evaluateJsToString(jsString: "HighlightFromIndex(\(location), \(length));\"OK\";", completionHandler: nil)
        evaluateJsToString(jsString: "HighlightFromIndex(\(location), \(length)); ScrollToIndex(\(location) + \(length), \(scrollRatio)); \"OK\";", completionHandler: nil)
    }
    func getSelectedLocation(completionHandler:((Int?)->Void)?){
        evaluateJsToDouble(jsString: "GetSelectedIndex();") { (result) in
            if let result = result, result.isNaN == false, result.isInfinite == false {
                completionHandler?(Int(result))
            }else{
                completionHandler?(nil)
            }
        }
    }
    func getSelectedString(completionHandler:((String?)->Void)?){
        evaluateJsToString(jsString: "GetSelectedString();") { result in
            completionHandler?(result)
        }
    }
    func getSelectedRange(completionHandler:@escaping ((Int?,Int?)->Void)){
        evaluateJsToStringDoubleDictionary(jsString: "GetSelectedRange();") { result in
            guard let result = result, let startIndex = result["startIndex"], let endIndex = result["endIndex"] else {
                completionHandler(nil, nil)
                return
            }
            completionHandler(NiftyUtility.DoubleToInt(value: startIndex), NiftyUtility.DoubleToInt(value: endIndex))
        }
    }
    func hideNotPageElement(completionHandler: (()->Void)?){
        evaluateJsToString(jsString: "HideOtherElements(document.body, elementArray);\"OK\";", completionHandler: { _ in
            completionHandler?()
        })
    }
    
    func convertNovelSepakerStringToHTML(text:String) -> String {
        return text.replacingOccurrences(of: "\\|([^|(]+?)[(]([^)]+?)[)]", with: "<ruby> $1<rt> $2 </rt></ruby>", options: .regularExpression, range: text.range(of: text)).replacingOccurrences(of: "\r\n", with: "  <br>").replacingOccurrences(of: "\n", with: " <br>")
    }
    
    func createContentHTML(content:String, foregroundColor:UIColor, backgroundColor:UIColor, displaySetting: RealmDisplaySetting?) -> String {
        var fontSetting:String = "font: -apple-system-title1;"
        var fontSize:String = "18px"
        var letterSpacing:String = "0.03em"
        var lineHeight:String = "1.5em"
        var verticalModeCSS:String = ""
        let foregroundColorCSS:String
        if let fgColor = foregroundColor.cssColor {
            foregroundColorCSS = "color: \(fgColor)"
        }else{
            foregroundColorCSS = ""
        }
        let backgroundColorCSS:String
        if let bgColor = backgroundColor.cssColor {
            backgroundColorCSS = "background-color: \(bgColor)"
        }else{
            backgroundColorCSS = ""
        }

        if let displaySetting = displaySetting {
            let displayFont = displaySetting.font
            let fontWeight = displayFont.fontDescriptor.symbolicTraits.contains(.traitBold) ? "bold" : "normal"
            let fontStyle = displayFont.fontDescriptor.symbolicTraits.contains(.traitItalic) ? "italic" : "normal"
            fontSetting = "font-family: '\(displaySetting.font.familyName)'; font-weight: \(fontWeight); font-style: \(fontStyle);"
            fontSize = "\(displayFont.lineHeight)px"
            let lineSpacePix = displayFont.lineHeight + displaySetting.lineSpacingDisplayValue
            lineHeight = "\(lineSpacePix)px"
            verticalModeCSS = displaySetting.viewType == .webViewVertical ? "writing-mode: vertical-rl;" : ""
            print("\(fontSetting), font-size: \(fontSize), lineSpacePix: \(lineSpacePix), pointSize: \(displayFont.pointSize), font.xHeight: \(displaySetting.font.xHeight), CSS line-height: \(lineHeight), UIFont.lineHeight: \(displayFont.lineHeight), lineSpacingDisplayValue: \(displaySetting.lineSpacingDisplayValue), ascender: \(displayFont.ascender), descender: \(displayFont.descender), capHeight: \(displayFont.capHeight), leading: \(displayFont.leading) vertical: \"\(verticalModeCSS)\")")
        }
        
        let htmledText = convertNovelSepakerStringToHTML(text: content)
        /* goole font を読み込む場合はこうするよのメモ
         <html>
         <head>
         <style type="text/css">
         @import url('https://fonts.googleapis.com/css2?family=Hachi+Maru+Pop&display=swap');
         html {
           font-family: 'Hachi Maru Pop', cursive;
           font-size: \(fontPixelSize);
           letter-spacing: \(letterSpacing);
           line-height: \(lineHeight);
           font-feature-settings: 'pkna';
           \(verticalModeCSS)
         }
         */
        let html = """
<html>
<head>
<style type="text/css">
html {
  \(fontSetting)
  font-size: \(fontSize);
  letter-spacing: \(letterSpacing);
  line-height: \(lineHeight);
  font-feature-settings: 'pkna';
  \(verticalModeCSS)
}
ruby rt {
    font-size: 0.65em;
}
body.NovelSpeakerBody {
  \(foregroundColorCSS);
  \(backgroundColorCSS);
}
* {
  scroll-behavior: smooth;
}
</style>
</head>
<html><body class="NovelSpeakerBody">
"""
        + htmledText
        + """
</body></html>
"""
        return html
    }
    

}
