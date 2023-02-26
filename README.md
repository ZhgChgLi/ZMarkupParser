![ZMarkupParser](https://user-images.githubusercontent.com/33706588/219608966-20e0c017-d05c-433a-9a52-091bc0cfd403.jpg)

<p align="center">
  <a href="https://codecov.io/gh/ZhgChgLi/ZMarkupParser" target="_blank"><img src="https://codecov.io/gh/ZhgChgLi/ZMarkupParser/branch/main/graph/badge.svg?token=MPzgO1tnr9"></a>
  <a href="https://github.com/ZhgChgLi/ZMarkupParser/actions/workflows/ci.yml" target="_blank"><img src="https://github.com/ZhgChgLi/ZMarkupParser/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://cocoapods.org/pods/ZMarkupParser" target="_blank"><img src="https://img.shields.io/cocoapods/v/ZMarkupParser.svg?style=flat"></a>
  <a href="https://swift.org/package-manager/" target="_blank"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
  <br />
  <a href="https://raw.githubusercontent.com/ZhgChgLi/ZMarkupParser/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/ZMarkupParser.svg?style=flat" target="_blank"></a>
  <a href="https://github.com/ZhgChgLi/ZMarkupParser" target="_blank"><img src="https://img.shields.io/cocoapods/p/ZMarkupParser.svg?style=flat"></a>
</p>

ZMarkupParser is a pure-Swift library that helps you to convert HTML strings to NSAttributedString with customized style and tags.

[中文](https://medium.com/zrealm-ios-dev/zmarkupparser-html-string-%E8%BD%89%E6%8F%9B-nsattributedstring-%E5%B7%A5%E5%85%B7-a5643de271e4)

## Features
- [x] Parse HTML strings using pure-Swift and regular expressions.
- [x] Automatically correct invalid HTML strings, including mixed or isolated tags (e.g., `<a>Link<b>LinkBold</a>Bold</b><br>` -> `<a>Link<b>LinkBold</b></a><b>Bold</b><br/>`).
- [x] More compatible with HTML tags than a parser that is based on XMLParser.
- [x] Customizable HTML tag parser with painless extended tag support and the ability to customize tag styles.
- [x] Support for HTML rendering, stripping, and selecting.
- [x] Support for `<ul>` and `<ol>` list views and `<hr>` horizontal lines, and more.
- [x] Support for parsing and setting styles from HTML tag attributes such as style="color:red".
- [x] Support for parsing HTML color names into UIColor/NSColor.
- [x] Better performance compared to `NSAttributedString.DocumentType.html`.

## Try it!
<img src="https://user-images.githubusercontent.com/33706588/220594721-828eb404-dd2b-4bae-a7e6-56a92042e9a1.png" width="30%" height="30%"/>

To run the ZMarkupParser demo, download the repository and open ZMarkupParser.xcworkspace. Then, select the ZMarkupParser-Demo target and run it to start exploring the library. Enjoy!

### Performance Benchmark

[![Performance Benchmark](https://user-images.githubusercontent.com/33706588/221342800-d7891cb3-af1a-4fe9-a8f1-c7b963e11f95.png)](https://quickchart.io/chart-maker/view/zm-73887470-e667-4ca3-8df0-fe3563832b0b)

(2022/M2/24GB Memory/macOS 13.2/XCode 14.1)

Note that rendering an NSAttributedString with the DocumentType.html option can cause a crash when the length of the HTML string exceeds 54,600+ characters. To avoid this issue, consider using ZMarkupParser instead.

The chart above shows the elapsed time (in seconds) to render different HTML string lengths (x). As you can see, ZMarkupParser performs better than NSAttributedString.DocumentType.html, especially for larger HTML strings.

## Installation

### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/ZhgChgLi/ZMarkupParser.git`
- Select "Up to Next Major" with "1.2.5"

or 

```swift
...
dependencies: [
  .package(url: "https://github.com/ZhgChgLi/ZMarkupParser.git", from: "1.2.5"),
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
  pod 'ZMarkupParser', '~> 1.2.5'
end
```

## How it works? (explain with Pseudocode)
1. Input html string: `<a>Link<b>LinkBold</a>Bold</b>`
2. Convert string to array of tag element through Regex:
```
[
  {tagStart: "a"},
  {string: "Link"},
  {tagStart: "b"},
  {string: "LinkBold"},
  {tagClose: "a"},
  {string: "Bold"},
  {tagClose: "b"}
]
```
3. Traverse tag element array to autocorrect mixed tags and find isolated tags:
```
[
  {tagStart: "a"},
  {string: "Link"},
  {tagStart: "b"},
  {string: "LinkBold"},
  {tagClose: "b"},
  {tagClose: "a"},
  {tagStart: "b"},
  {string: "Bold"},
  {tagClose: "b"}
]
```
4. Convert tag element array to abstract syntax tree:
```
RootMarkup
|--A
|  |--String("Link")
|  |--B
|     |--String("LinkBold")
|
|--B
   |--String("Bold")
```
5. Map tag to abstract Markup/MarkupStyle:
```
RootMarkup
|--A(underline=true)
|  |--String("Link")(color=blue, font=13pt)
|  |--B
|     |--String("LinkBold")(color=blue, font=18pt, bold=true)
|
|--B(font=18pt, bold=true)
```
6. Use Visitor Pattern to visit every tree leaf Markup/MarkupStyle and combine it to NSAttributedString through recursion.

Result:
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

ZMarkupParser provides a set of pre-defined tag names that map to abstract markup classes, such as A_HTMLTagName() for <a></a>, B_HTMLTagName() for <b></b>, and so on. This mapping is used to create instances of the corresponding markup classes during the parsing process.

In addition, if there is a tag that is not defined or you want to customize your own tag, you can use the `ExtendTagName(tagName: String)` method to create a custom tag name and map it to an abstract markup class of your own design.

```swift
A_HTMLTagName(), // <a></a>
B_HTMLTagName(), // <b></b>
BR_HTMLTagName(), // <br></br> and also <br/>
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

### MarkupStyle/MarkupStyleColor/MarkupStyleParagraphStyle
The MarkupStyle wrapper contains various properties that are used to define the attributes of an NSAttributedString. These properties includes:
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

For example, you can initialize or define a MarkupStyle object with the properties you want, such as setting the font size to 13 and the background color to aquamarine:
```swift
MarkupStyle(font: MarkupStyleFont(size: 13), backgroundColor: MarkupStyleColor(name: .aquamarine))
```

### HTMLTagStyleAttribute

These are pre-defined style attributes that can be used in the conversion of HTML tags to NSAttributedString attributes. Each style attribute has a corresponding class that defines its behavior and how it should be applied to the NSAttributedString.

```swift
ColorHTMLTagStyleAttribute(), // color
BackgroundColorHTMLTagStyleAttribute(), // background-color
FontSizeHTMLTagStyleAttribute(), // font-size
FontWeightHTMLTagStyleAttribute(), // font-weight
LineHeightHTMLTagStyleAttribute(), // line-height
WordSpacingHTMLTagStyleAttribute(), // word-spacing
```

If there is a style attribute that is not defined, the ExtendHTMLTagStyleAttribute class can be used to define it. This class takes in a style name and a closure that takes in an existing style and the value of the new style attribute and returns a new style with the new attribute applied.

For exmaple: `style="text-decoration"`
```swift
ExtendHTMLTagStyleAttribute(styleName: "text-decoration", render: { fromStyle, value in
  var newStyle = fromStyle
  if value == "underline" {
    newStyle.underline = NSUnderlineStyle.single
  } else {
    // ...  
  }
  return newStyle
})
```

## Usage
```swift
import ZMarkupParser
```

### Builder Pattern to Build Parser
```swift
let parser = ZHTMLParserBuilder.initWithDefault().set(rootStyle: MarkupStyle(font: MarkupStyleFont(size: 13)).build()
```

The code initializes a new ZHTMLParserBuilder object with default settings using the `initWithDefault()` method. This method adds all pre-defined HTML tag names and style attributes, and sets the tag's default MarkupStyle to render.

Then, the `set(rootStyle: MarkupStyle)` method is called to specify the default root style to render. This root style will be applied to the entire attributed string that is generated by the parser.

Finally, the `build()` method is called at the end to generate the parser object.

#### Customized Tag Style/Extend Tag Name

These code snippets demonstrate how to customize the style of a tag or extend the tag name:

To customize the style of a tag, you can use the add method of the ZHTMLParserBuilder class and provide an instance of HTMLTagName and a MarkupStyle object as parameters. For example, the following code snippet will use a custom markup style to render the <b></b> tag:
```swift
let parser = ZHTMLParserBuilder.initWithDefault().add(B_HTMLTagName(), withCustomStyle: MarkupStyle(font: MarkupStyleFont(size: 18, weight: .style(.semibold)))).build()
```

To extend the tag name and customize its style, you can use the ExtendTagName class and the add method of the ZHTMLParserBuilder class. For example, the following code snippet will extend the tag name to <zhgchgli></zhgchgli> and use a custom markup style to render it:
```swift
let parser = ZHTMLParserBuilder.initWithDefault().add(ExtendTagName("zhgchgli"), withCustomStyle: MarkupStyle(backgroundColor: MarkupStyleColor(name: .aquamarine))).build()
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
- Parsing <img> tags is currently not supported because inserting images using NSTextAttachment in UITextView can lead to out-of-memory issues, especially when parsing large amounts of HTML.
- To change the style of links in UITextView, you need to set the linkTextAttributes property to an NSAttributedString.Key value that includes the desired style properties.
- If you're using a UILabel to render attributed strings, note that you can't change the color of .link text using the NSAttributedString.Key.foregroundColor attribute.
- The ZHTMLParser library is intended for rendering partial HTML content, and may not be suitable for rendering very large or complex HTML documents. For these use cases, it's better to use a web view to render the HTML content.

## Who is using
[![pinkoi](https://user-images.githubusercontent.com/33706588/221343295-3e3831e6-f76d-430a-87e3-4daf9815297d.jpg)](https://en.pinkoi.com)

[Pinkoi.com](https://en.pinkoi.com) is Asia's leading online marketplace for original design goods, digital creations, and workshop experiences.

## About
- [ZhgChg.Li (CH)](https://zhgchg.li/)
- [ZhgChgLi's Medium (CH)](https://blog.zhgchg.li/)

[![Buy Me A Coffe](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20beer!&emoji=%F0%9F%8D%BA&slug=zhgchgli&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/zhgchgli)

If you find this library helpful, please consider starring the repo or recommending it to your friends.

Feel free to open an issue or submit a fix/contribution via pull request. :)
