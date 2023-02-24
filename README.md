![ZMarkupParser](https://user-images.githubusercontent.com/33706588/219608966-20e0c017-d05c-433a-9a52-091bc0cfd403.jpg)

<p align="center">
  <a href="https://codecov.io/gh/ZhgChgLi/ZMarkupParser" target="_blank"><img src="https://codecov.io/gh/ZhgChgLi/ZMarkupParser/branch/main/graph/badge.svg?token=MPzgO1tnr9"></a>
  <a href="https://cocoapods.org/pods/ZMarkupParser" target="_blank"><img src="https://img.shields.io/cocoapods/v/ZMarkupParser.svg?style=flat"></a>
  <a href="https://swift.org/package-manager/" target="_blank"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
  <br />
  <a href="https://raw.githubusercontent.com/ZhgChgLi/ZMarkupParser/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/ZMarkupParser.svg?style=flat" target="_blank"></a>
  <a href="https://github.com/ZhgChgLi/ZMarkupParser" target="_blank"><img src="https://img.shields.io/cocoapods/p/ZMarkupParser.svg?style=flat"></a>
</p>

ZMarkupParser helps you to convert HTML String to NSAttributedString with customized style and tag through pure-Swift.

## Features
- [x] Parse HTML String through Rexgex with pure-Swift.
- [x] Autocorrect invalid HTML string, including mixed or isolated tag. (e.g. `<a>Link<b>LinkBold</a>Bold</b><br>` -> `<a>Link<b>LinkBold</b></a><b>Bold</b><br/>`)
- [x] Painless extended HTML Tag Parser and customized HTML Tag Style you wish.
- [x] Support HTML Render/HTML Stripper/HTML Selector
- [x] Support `<ul><ol>` list view and `<hr>` horizontal line...etc
- [x] Support parse & set style from html tag `style="color:red"` attributes.
- [x] Support parse HTML Color name to UIColor/NSColor.
- [x] Higher performance than `NSAttributedString.DocumentType.html`

## Try it!
<img src="https://user-images.githubusercontent.com/33706588/220594721-828eb404-dd2b-4bae-a7e6-56a92042e9a1.png" width="30%" height="30%"/>

downloaded repo and open `ZMarkupParser.xcworkspace`, select target to `ZMarkupParser-Demo` run it! have fun!

### Performance Benchmark

[![chart (1)](https://user-images.githubusercontent.com/33706588/221120878-d5bcb131-f13d-48f4-8ed2-aac0c545a23b.png)](https://quickchart.io/chart-maker/view/zm-a8243b19-d59d-4ae2-81c6-2ebb5797e017)

(2022/M2/24GB Memory/macOS 13.2/XCode 14.1)

`NSAttributedString.DocumentType.html` **will crashed when render more than 54,600+ length of string.**

- **x**: html string length
- **y**: time elapsed(second)

## Installation

### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/ZhgChgLi/ZMarkupParser.git`
- Select "Up to Next Major" with "1.1.6"

or 

```swift
...
dependencies: [
  .package(url: "https://github.com/ZhgChgLi/ZMarkupParser.git", from: "1.1.6"),
]
...
.target(
    ...
    dependencies: [
        "ZMarkupParser",
    ],
    ...
)
```

### CocoaPods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'ZMarkupParser', '~> 1.1.6'
end
```

## How it works? (explain with Pseudocode)
1. Input html string: `<a>Link<b>LinkBold</a>Bold</b>`
2. Convert string to array of tag element through Regex: `[{tagStrat: a}, {string: Link}, {tagStart: b}, {string: LinkBold}, {tagClose: a}, {string: Bold}, {tagClose: b}]`
3. Traversal tag element array to autocorrent mixed tag and find isolated tag: `[{tagStrat: a}, {string: Link}, {tagStart: b}, {string: LinkBold}, {tagClose: b}, {tagClose: a}, {tagStart: b}, {string: Bold}, {tagClose: b}]`
4. Convert tag element array to abstract syntax tree:
```
//                     RootMarkup
//                  /               \
//                 A                 B
//          /             \          |
//    String("Link")       B    String("Bold")  
//                         |
//                  String("LinkBold")
//                                
```
5. Mapping tag to abstract Markup/MarkupStyle
6. Use Visitor Pattern to visit every tree leaf Markup/MarkupStyle and combine it to NSAttributedString through recursion.
7. Result:
```
Link{
    NSColor = "UIExtendedSRGBColorSpace 0 0.478431 1 1";
    NSFont = "<UICTFont: 0x145d17600> font-family: \".SFUI-Regular\"; font-weight: normal; font-style: normal; font-size: 13.00pt";
    NSUnderline = 1;
}LinkBold{
    NSColor = "UIExtendedSRGBColorSpace 0 0.478431 1 1";
    NSFont = "<UICTFont: 0x145d18710> font-family: \".SFUI-Semibold\"; font-weight: bold; font-style: normal; font-size: 18.00pt";
    NSUnderline = 1;
}Bold{
    NSFont = "<UICTFont: 0x145d18710> font-family: \".SFUI-Semibold\"; font-weight: bold; font-style: normal; font-size: 18.00pt";
}
```
### Example
![ZMarkupParser Exmple](https://user-images.githubusercontent.com/33706588/220371406-d458f810-4dee-4f22-a161-b956fc626ccc.jpg)


## Introduction
### HTMLTagName
Abstract of html tag, there is some pre-defined html tag name down below.
```swift
A_HTMLTagName(), // <a></a>
B_HTMLTagName(), // <b></b>
BR_HTMLTagName(), // <br></br>
DIV_HTMLTagName(), // <div></div>
HR_HTMLTagName(), // <hr></hr>
I_HTMLTagName(), // <i></i>
LI_HTMLTagName(), // <li></li>
OL_HTMLTagName(), // <ol></ol>
P_HTMLTagName(), // <p></p>
SPAN_HTMLTagName(), // <span></span>
STRONG_HTMLTagName(), // <strong></strong>
U_HTMLTagName(), // <u></u>
UL_HTMLTagName(), // <ul></ul>
DEL_HTMLTagName(), // <del></del>
...
```
If there is HTML tag not be defined or customized tag, you could use `ExtendTagName("tagName")` to wrapped it.

### MarkupStyle/MarkupStyleColor/MarkupStyleParagraphStyle
Wrapper of `NSAttributedStrin.Key` because of inheritable puerpose.
```swift
var font:MarkupStyleFont
var paragraphStyle:MarkupStyleParagraphStyle
var foregroundColor:MarkupStyleColor? = nil
var backgroundColor:MarkupStyleColor? = nil
var ligature:NSNumber? = nil
var kern:NSNumber? = nil
var tracking:NSNumber? = nil
var strikethroughStyle:NSUnderlineStyle? = nil
var underlineStyle:NSUnderlineStyle? = nil
var strokeColor:MarkupStyleColor? = nil
var strokeWidth:NSNumber? = nil
var shadow:NSShadow? = nil
var textEffect:String? = nil
var attachment:NSTextAttachment? = nil
var link:URL? = nil
var baselineOffset:NSNumber? = nil
var underlineColor:MarkupStyleColor? = nil
var strikethroughColor:MarkupStyleColor? = nil
var obliqueness:NSNumber? = nil
var expansion:NSNumber? = nil
var writingDirection:NSNumber? = nil
var verticalGlyphForm:NSNumber? = nil
...
```
You could init or define MarkupStyle you want.
```swift
MarkupStyle(font: MarkupStyleFont(size: 13), backgroundColor: MarkupStyleColor(name: .aquamarine))
```

### HTMLTagStyleAttribute
Abstract of html style attributes, there is some pre-defined attributes down below.
```swift
ColorHTMLTagStyleAttribute(), // color
BackgroundColorHTMLTagStyleAttribute(), // background-color
FontSizeHTMLTagStyleAttribute(), // font-size
FontWeightHTMLTagStyleAttribute(), // font-weight
LineHeightHTMLTagStyleAttribute(), // line-height
WordSpacingHTMLTagStyleAttribute(), // word-spacing
```
If there is Style attribute not be defined, you could use `ExtendHTMLTagStyleAttribute("styleAttributeName", MarkupStyle)` to wrapped it.

## Usage
```swift
import ZMarkupParser
```

### Builder Pattern to Build Parser
```swift
let parser = ZHTMLParserBuilder.initWithDefault().set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13)).build()
```

`initWithDefault()` will add all pre-defined HTMLTagName/HTMLTagStyleAttribute and use Tag's default MarkupStyle to render.

`set(rootStyle:MarkupStyle)` specify default root style to render, will apply to whole attributed string.

`build()` call build() at the end, to generate parser object.

#### Customized Tag Style/Extend Tag Name
```swift
let parser = ZHTMLParserBuilder.initWithDefault().add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))) // will use markupstyle you specify to render <b></b> instead of default bold markup style
```

```swift
let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName("zhgchgli"), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))) // will use markupstyle you specify to render extend html tag <zhgchgli></zhgchgli>
```


### Parse HTML String
```swift
parser.render(htmlString) // NSAttributedString

// work with UITextView
textView.setHtmlString(htmlString)

// work with UILabel
label.setHtmlString(htmlString)
```

### Stripper HTML String
```swift
parser.stripper(htmlString) // NSAttributedString
```

### Selector HTML String
```swift
let selector = parser.selector(htmlString) // HTMLSelector e.g. input: <a><b>Test</b>Link</a>
selector.first("a")?.first("b").attributedString // will return Test
selector.filter("a").attributedString // will return Test Link
```

### Selector+Render HTML String
```swift
let selector = parser.selector(htmlString) // HTMLSelector e.g. input: <a><b>Test</b>Link</a>
parser.render(selector.first("a")?.first("b"))
```

### With Async
```swift
parser.render(String) { _ in }...
parser.stripper(String) { _ in }...
parser.selector(String) { _ in }...
```
If you want to render huge html string, please use async instead.

## Things to know
- Unsupport Parse `<img>` to NSTextAttacment currently, due to need async task & native textview with NSTextAttacment didn't impletation reuse, insert image throught NSTextAttacment to TextView will lead to Out of memory.
- Need to set `linkTextAttributes` for UITextView to change .link style
- UILabel is not allow to change .link text color style throught NSAttributedString.key.foregroundColor
- Due to limitation, colud only use this parser render in partial html, do not use in redner whole huge html (please use webview.loadhtml instead.)

## Made In Taiwan 🇹🇼🇹🇼🇹🇼
- [ZhgChg.Li (CH)](https://zhgchg.li/)
- [ZhgChgLi's Medium (CH)](https://blog.zhgchg.li/)


[![Buy Me A Coffe](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20beer!&emoji=%F0%9F%8D%BA&slug=zhgchgli&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/zhgchgli)

If this is helpful, please help to star the repo or recommend it to your friends.

Please feel free to open an Issue or submit a fix/contribution via Pull Request. :)
