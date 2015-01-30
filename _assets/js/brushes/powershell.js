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
!function(){function a(){var a="while validateset validaterange validatepattern validatelength validatecount until trap switch return ref process param parameter in if global: function foreach for finally filter end elseif else dynamicparam do default continue cmdletbinding break begin alias \\? % #script #private #local #global mandatory parametersetname position valuefrompipeline valuefrompipelinebypropertyname valuefromremainingarguments helpmessage ",b=" and as band bnot bor bxor casesensitive ccontains ceq cge cgt cle clike clt cmatch cne cnotcontains cnotlike cnotmatch contains creplace eq exact f file ge gt icontains ieq ige igt ile ilike ilt imatch ine inotcontains inotlike inotmatch ireplace is isnot le like lt match ne not notcontains notlike notmatch or regex replace wildcard",c="write where wait use update unregister undo trace test tee take suspend stop start split sort skip show set send select scroll resume restore restart resolve resize reset rename remove register receive read push pop ping out new move measure limit join invoke import group get format foreach export expand exit enter enable disconnect disable debug cxnew copy convertto convertfrom convert connect complete compare clear checkpoint aggregate add",d=" component description example externalhelp forwardhelpcategory forwardhelptargetname forwardhelptargetname functionality inputs link notes outputs parameter remotehelprunspace role synopsis";this.regexList=[{regex:new RegExp("^\\s*#[#\\s]*\\.("+this.getKeywords(d)+").*$","gim"),css:"preprocessor help bold"},{regex:SyntaxHighlighter.regexLib.singleLinePerlComments,css:"comments"},{regex:/(&lt;|<)#[\s\S]*?#(&gt;|>)/gm,css:"comments here"},{regex:new RegExp('@"\\n[\\s\\S]*?\\n"@',"gm"),css:"script string here"},{regex:new RegExp("@'\\n[\\s\\S]*?\\n'@","gm"),css:"script string single here"},{regex:new RegExp('"(?:\\$\\([^\\)]*\\)|[^"]|`"|"")*[^`]"',"g"),css:"string"},{regex:new RegExp("'(?:[^']|'')*'","g"),css:"string single"},{regex:new RegExp("[\\$|@|@@](?:(?:global|script|private|env):)?[A-Z0-9_]+","gi"),css:"variable"},{regex:new RegExp("(?:\\b"+c.replace(/ /g,"\\b|\\b")+")-[a-zA-Z_][a-zA-Z0-9_]*","gmi"),css:"functions"},{regex:new RegExp(this.getKeywords(a),"gmi"),css:"keyword"},{regex:new RegExp("-"+this.getKeywords(b),"gmi"),css:"operator value"},{regex:new RegExp("\\[[A-Z_\\[][A-Z0-9_. `,\\[\\]]*\\]","gi"),css:"constants"},{regex:new RegExp("\\s+-(?!"+this.getKeywords(b)+")[a-zA-Z_][a-zA-Z0-9_]*","gmi"),css:"color1"}]}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["powershell","ps","posh"],SyntaxHighlighter.brushes.PowerShell=a,"undefined"!=typeof exports?exports.Brush=a:null}();