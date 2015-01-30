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
!function(){function a(){this.regexList=[{regex:/^\+\+\+ .*$/gm,css:"color2"},{regex:/^\-\-\- .*$/gm,css:"color2"},{regex:/^\s.*$/gm,css:"color1"},{regex:/^@@.*@@.*$/gm,css:"variable"},{regex:/^\+.*$/gm,css:"string"},{regex:/^\-.*$/gm,css:"color3"}]}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["diff","patch"],SyntaxHighlighter.brushes.Diff=a,"undefined"!=typeof exports?exports.Brush=a:null}();