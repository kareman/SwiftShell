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
!function(){function a(){function a(a){var b=SyntaxHighlighter.Match,c=[];return null!=a.here_doc&&c.push(new b(a.here_doc,a.index+a[0].indexOf(a.here_doc),"string")),null!=a.full_tag&&c.push(new b(a.full_tag,a.index,"preprocessor")),null!=a.end_tag&&c.push(new b(a.end_tag,a.index+a[0].lastIndexOf(a.end_tag),"preprocessor")),c}var b="if fi then elif else for do done until while break continue case esac function return in eq ne ge le",c="alias apropos awk basename base64 bash bc bg builtin bzip2 cal cat cd cfdisk chgrp chmod chown chrootcksum clear cmp comm command cp cron crontab crypt csplit cut date dc dd ddrescue declare df diff diff3 dig dir dircolors dirname dirs du echo egrep eject enable env ethtool eval exec exit expand export expr false fdformat fdisk fg fgrep file find fmt fold format free fsck ftp gawk gcc gdb getconf getopts grep groups gzip hash head history hostname id ifconfig import install join kill less let ln local locate logname logout look lpc lpr lprint lprintd lprintq lprm ls lsof make man mkdir mkfifo mkisofs mknod more mount mtools mv nasm nc ndisasm netstat nice nl nohup nslookup objdump od open op passwd paste pathchk ping popd pr printcap printenv printf ps pushd pwd quota quotacheck quotactl ram rcp read readonly renice remsync rm rmdir rsync screen scp sdiff sed select seq set sftp shift shopt shutdown sleep sort source split ssh strace strings su sudo sum symlink sync tail tar tee test time times touch top traceroute trap tr true tsort tty type ulimit umask umount unalias uname unexpand uniq units unset unshar useradd usermod users uuencode uudecode v vdir vi watch wc whereis which who whoami Wget xargs xxd yes chsh";this.regexList=[{regex:/^#!.*$/gm,css:"preprocessor bold"},{regex:/\/[\w-\/]+/gm,css:"plain"},{regex:SyntaxHighlighter.regexLib.singleLinePerlComments,css:"comments"},{regex:SyntaxHighlighter.regexLib.doubleQuotedString,css:"string"},{regex:SyntaxHighlighter.regexLib.singleQuotedString,css:"string"},{regex:new RegExp(this.getKeywords(b),"gm"),css:"keyword"},{regex:new RegExp(this.getKeywords(c),"gm"),css:"functions"},{regex:new XRegExp("(?<full_tag>(&lt;|<){2}(?<tag>\\w+)) .*$(?<here_doc>[\\s\\S]*)(?<end_tag>^\\k<tag>$)","gm"),func:a}]}SyntaxHighlighter=SyntaxHighlighter||("undefined"!=typeof require?require("shCore").SyntaxHighlighter:null),a.prototype=new SyntaxHighlighter.Highlighter,a.aliases=["bash","shell","sh"],SyntaxHighlighter.brushes.Bash=a,"undefined"!=typeof exports?exports.Brush=a:null}();