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
!function(){function a(){function a(a){var b=SyntaxHighlighter.Match,c=a[0],d=XRegExp.exec(c,XRegExp("(&lt;|<)[\\s\\/\\?!]*(?<name>[:\\w-\\.]+)","xg")),e=[];if(null!=a.attributes)for(var f,g=0,h=XRegExp("(?<name> [\\w:.-]+)\\s*=\\s*(?<value> \".*?\"|'.*?'|\\w+)","xg");null!=(f=XRegExp.exec(c,h,g));)e.push(new b(f.name,a.index+f.index,"color1")),e.push(new b(f.value,a.index+f.index+f[0].indexOf(f.value),"string")),g=f.index+f[0].length;return null!=d&&e.push(new b(d.name,a.index+d[0].indexOf(d.name),"keyword")),e}this.regexList=[{regex:XRegExp("(\\&lt;|<)\\!\\[[\\w\\s]*?\\[(.|\\s)*?\\]\\](\\&gt;|>)","gm"),css:"color2"},{regex:SyntaxHighlighter.regexLib.xmlComments,css:"comments"},{regex:XRegExp("(&lt;|<)[\\s\\/\\?!]*(\\w+)(?<attributes>.*?)[\\s\\/\\?]*(&gt;|>)","sg"),func:a}]}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["xml","xhtml","xslt","html","plist"],SyntaxHighlighter.brushes.Xml=a,"undefined"!=typeof exports?exports.Brush=a:null}();