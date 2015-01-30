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
!function(){function a(){var a="class interface package macro enum typedef extends implements dynamic in for if while else do try switch case catch",b="return break continue new throw cast using import function public private inline static untyped callback true false null Int Float String Void Std Bool Dynamic Array Vector";this.regexList=[{regex:SyntaxHighlighter.regexLib.singleLineCComments,css:"comments"},{regex:SyntaxHighlighter.regexLib.multiLineCComments,css:"comments"},{regex:SyntaxHighlighter.regexLib.doubleQuotedString,css:"string"},{regex:SyntaxHighlighter.regexLib.singleQuotedString,css:"string"},{regex:/\b([\d]+(\.[\d]+)?|0x[a-f0-9]+)\b/gi,css:"value"},{regex:new RegExp(this.getKeywords(a),"gm"),css:"color3"},{regex:new RegExp(this.getKeywords(b),"gm"),css:"keyword"},{regex:new RegExp("var","gm"),css:"variable"},{regex:new RegExp("trace","gm"),css:"color1"},{regex:new RegExp("#if","gm"),css:"comments"},{regex:new RegExp("#elseif","gm"),css:"comments"},{regex:new RegExp("#end","gm"),css:"comments"},{regex:new RegExp("#error","gm"),css:"comments"}];var c,d=["debug","error","cpp","js","neko","php","flash","flash8","flash9","flash10","flash10","mobile","desktop","web","ios","android","iphone"],e=d.length;for(c=0;e-1>=c;c++)this.regexList.push({regex:new RegExp(d[c],"gm"),css:"comments"}),this.regexList.push({regex:new RegExp("!"+d[c],"gm"),css:"comments"});this.forHtmlScript(SyntaxHighlighter.regexLib.scriptScriptTags)}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["haxe","hx"],SyntaxHighlighter.brushes.Haxe=a,"undefined"!=typeof exports?exports.Brush=a:null}();