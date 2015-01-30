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
!function(){function a(){this.regexList=[{regex:new RegExp("^1..\\d+","gm"),css:"plain bold italic"},{regex:new RegExp("^ok( \\d+)?","gm"),css:"keyword"},{regex:new RegExp("^not ok( \\d+)?","gm"),css:"color3 bold"},{regex:new RegExp("(?!^\\s*)#.*$","gm"),css:"variable bold"},{regex:new RegExp("^#.*$","gm"),css:"comments bold"},{regex:new RegExp("^(?!(not )?ok)[^1].*$","gm"),css:"comments"},{regex:SyntaxHighlighter.regexLib.doubleQuotedString,css:"string"},{regex:SyntaxHighlighter.regexLib.singleQuotedString,css:"string"}]}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["tap","Tap","TAP"],SyntaxHighlighter.brushes.TAP=a,"undefined"!=typeof exports?exports.Brush=a:null}();