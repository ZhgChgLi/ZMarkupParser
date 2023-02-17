![ZMarkupParser](https://user-images.githubusercontent.com/33706588/219608966-20e0c017-d05c-433a-9a52-091bc0cfd403.jpg)

<p align="center">
  <a href="https://codecov.io/gh/ZhgChgLi/ZMarkupParser"><img src="https://codecov.io/gh/ZhgChgLi/ZMarkupParser/branch/main/graph/badge.svg?token=MPzgO1tnr9"></a>
  <a href="https://cocoapods.org/pods/ZMarkupParser"><img src="https://img.shields.io/cocoapods/v/ZMarkupParser.svg?style=flat"></a>
  <a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
  <br />
  <a href="https://raw.githubusercontent.com/ZhgChgLi/ZMarkupParser/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/ZMarkupParser.svg?style=flat"></a>
  <a href="https://github.com/ZhgChgLi/ZMarkupParser"><img src="https://img.shields.io/cocoapods/p/ZMarkupParser.svg?style=flat"></a>
</p>

ZMarkupParser helps you to convert HTML String to NSAttributedString with customized style and tag.

## To Do
- [ ] Full test coverage
- [ ] Code Arch & Pattern Doc
- [ ] Documentation
- [ ] Demo App
- [ ] Full markdow symobl parse
- [ ] CI & CD

## Features
- [x] Parse HTML String through Rexgex with pure-Swift.
- [x] Autocorrect invalid HTML string, including mixed or isolated tag. (e.g. `<a>Link<b>LinkBold</a>Bold</b>` -> `<a>Link<b>LinkBold</b></a><b>Bold</b>`)
- [x] Painless extended HTML Tag Parser and customized HTML Tag Style you wish.
- [x] Faster than the origin `NSAttributedString.DocumentType.html`,  7.6+ times speed-up.
- [x] Support HTML Render/HTML Stripper/HTML Selector
- [x] Support Markdown Parser additionally (**Not ready to use, only support basic markdown sybmol parse, need contribute**)
- [x] Support `<ul><ol>` list view and `<hr>` horizontal line...etc
- [x] Support parse & set style from html tag `style="color:red"` attributes.
- [x] Support parse HTML Color name to UICOlor/NSColor.

## Installation

### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/ZhgChgLi/ZMarkupParser.git`
- Select "Up to Next Major" with "1.0.0"

### CocoaPods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'ZMarkupParser', '~> 1.0'
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
let parser = ZHTMLParserBuilder.initWithDefault().build(MarkupStyle(font: MarkupStyleFont(size: 13))
```

`initWithDefault()` will add all pre-defined HTMLTagName/HTMLTagStyleAttribute and use Tag's default MarkupStyle to render.

`build(RootStyle)` you need to specify default root style to render, will apply to whole attributed string.

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

## Made In Taiwan 🇹🇼🇹🇼🇹🇼
- [ZhgChg.Li (CH)](https://zhgchg.li/)
- [ZhgChgLi's Medium (CH)](https://blog.zhgchg.li/)


[![Buy Me A Coffe](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20beer!&emoji=%F0%9F%8D%BA&slug=zhgchgli&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/zhgchgli)

If this is helpful, please help to star the repo or recommend it to your friends.

Please feel free to open an Issue or submit a fix/contribution via Pull Request. :)
