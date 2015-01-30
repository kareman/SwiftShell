/**
 * SyntaxHighlighter
 * http://alexgorbatchev.com/SyntaxHighlighter
 *
 * SyntaxHighlighter is donationware. If you are using it, please donate.
 * http://alexgorbatchev.com/SyntaxHighlighter/donate.html
 *
 * @version
 *  ()
 *
 * @copyright
 * Copyright (C) 2004-2013 Alex Gorbatchev.
 *
 * @license
 * Dual licensed under the MIT and GPL licenses.
 */
!function(){function a(){var a="char bool BOOL double float int long short id void",b="IBAction IBOutlet SEL YES NO readwrite readonly nonatomic NULL super self copy if else for in enum while typedef switch case return const static retain TRUE FALSE ON OFF";this.regexList=[{regex:/^\s*(&gt;|>)(.*)$/gm,css:"output"},{regex:new RegExp(this.getKeywords(a),"gm"),css:"color2"},{regex:new RegExp(this.getKeywords(b),"gm"),css:"keyword"},{regex:new RegExp("@\\w+\\b","g"),css:"color1"},{regex:new RegExp("[: ]nil","g"),css:"color2"},{regex:new RegExp(" \\w+(?=[:\\]])","g"),css:"variable"},{regex:SyntaxHighlighter.regexLib.singleLineCComments,css:"comments"},{regex:SyntaxHighlighter.regexLib.multiLineCComments,css:"comments"},{regex:new RegExp('@"[^"]*"',"gm"),css:"string"},{regex:new RegExp("\\d","gm"),css:"value"},{regex:new RegExp("^ *#.*","gm"),css:"preprocessor"},{regex:new RegExp("\\w+(?= \\*)","g"),css:"keyword"},{regex:new RegExp("\\b[A-Z]\\w+\\b(?=[ ,;])","gm"),css:"keyword"},{regex:new RegExp("\\.\\w+","g"),css:"constants"}]}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["oc","objc","objective-c"],SyntaxHighlighter.brushes.ObjC=a,"undefined"!=typeof exports?exports.Brush=a:null}();