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
!function(){function a(){var a="class interface function package",b="-Infinity ...rest Array as AS3 Boolean break case catch const continue Date decodeURI decodeURIComponent default delete do dynamic each else encodeURI encodeURIComponent escape extends false final finally flash_proxy for get if implements import in include Infinity instanceof int internal is isFinite isNaN isXMLName label namespace NaN native new null Null Number Object object_proxy override parseFloat parseInt private protected public return set static String super switch this throw true try typeof uint undefined unescape use void while with";this.regexList=[{regex:SyntaxHighlighter.regexLib.singleLineCComments,css:"comments"},{regex:SyntaxHighlighter.regexLib.multiLineCComments,css:"comments"},{regex:SyntaxHighlighter.regexLib.doubleQuotedString,css:"string"},{regex:SyntaxHighlighter.regexLib.singleQuotedString,css:"string"},{regex:/\b([\d]+(\.[\d]+)?|0x[a-f0-9]+)\b/gi,css:"value"},{regex:new RegExp(this.getKeywords(a),"gm"),css:"color3"},{regex:new RegExp(this.getKeywords(b),"gm"),css:"keyword"},{regex:new RegExp("var","gm"),css:"variable"},{regex:new RegExp("trace","gm"),css:"color1"}],this.forHtmlScript(SyntaxHighlighter.regexLib.scriptScriptTags)}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["actionscript3","as3"],SyntaxHighlighter.brushes.AS3=a,"undefined"!=typeof exports?exports.Brush=a:null}();