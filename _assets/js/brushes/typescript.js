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
!function(){function a(){var a="break case catch class continue default delete do else enum export extends false  for function if implements import in instanceof interface let new null package private protected static return super switch this throw true try typeof var while with yield any bool declare get module number public set string",b=SyntaxHighlighter.regexLib;this.regexList=[{regex:b.multiLineDoubleQuotedString,css:"string"},{regex:b.multiLineSingleQuotedString,css:"string"},{regex:b.singleLineCComments,css:"comments"},{regex:b.multiLineCComments,css:"comments"},{regex:new RegExp(this.getKeywords(a),"gm"),css:"keyword"}],this.forHtmlScript(b.scriptScriptTags)}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["ts","typescript"],SyntaxHighlighter.brushes.TypeScript=a,"undefined"!=typeof exports?exports.Brush=a:null}();