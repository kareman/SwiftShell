if (!window.$) $ = jQuery;

/* Site-wide */

$(function() {
    // set up synxtaxhighlighter
    $('code[class^=language-]').each(function(idx, el) {
       $(el).attr('data-syntaxhighlighter', 'brush: ' + el.className.substr(9) + ';');
    });
    SyntaxHighlighter.all({'quick-code': false, 'gutter': false, 'callback': function() {        
        // link all the types
        $('.color2,.variable').each(function(i, item) {
            var i = item, t = item.innerText, repl = [item];
            while (i.nextSibling && (i.nextSibling.textContent == '.')) {
                t += '.' + i.nextSibling.nextSibling.textContent;
                repl.push(i.nextSibling);
                repl.push(i.nextSibling.nextSibling);
                i = i.nextSibling.nextSibling;
            }
            if (linkdata[t] && (linkdata[t].indexOf('/func/') == -1)) {
                $(item).before('<span class="color2"><a href="' + linkdata[t] + '">' + t + '</a></span>');
                $(repl).remove(); 
            }
        });
    }});
    
    // link non-synxtaxhighlighter sections
    $('.inherits,.nested').each(function(i, item) { 
        var text = item.innerText;
        var types = $(text.split(/[, ]+/)).each(function(i, type) {
            if (linkdata[type]) {
                text = text.replace(RegExp('\\b' + type + '\\b'), '<a href="' + linkdata[type] + '">' + type + '</a>');
            }
        });
        item.innerHTML = text;
    });
    
    // set up search box
    var selectdata = [ { text: 'Types', children:[] }, { text: 'Protocols', children:[] }, { text: 'Operators', children:[] }, { text: 'Globals', children:[] } ];
    var collapseAreas = [ '', '', '', '' ];
    var globalLinks = ['', ''];
    for (item in linkdata) {
        if (linkdata[item].match(/\/type\//)) {
            collapseAreas[0] += '<a href="' + linkdata[item] + '" class="list-group-item">' + item + '</a>';
            selectdata[0].children.push({ id: item, text: item });
        } else if (linkdata[item].match(/\/protocol\//)) {
            collapseAreas[1] += '<a href="' + linkdata[item] + '" class="list-group-item">' + item + '</a>';
            selectdata[1].children.push({ id: item, text: item });
        } else if (linkdata[item].match(/\/operator\//)) {
            collapseAreas[2] += '<a href="' + linkdata[item] + '" class="list-group-item">' + item + '</a>';
            selectdata[2].children.push({ id: item, text: item });
        } else if (linkdata[item].match(/\/(var)\//)) {
            globalLinks[0] = '<a href="' + linkdata[item] + '" class="list-group-item">Variables</a>';
            selectdata[3].children.push({ id: item, text: item });
        } else if (linkdata[item].match(/\/(alias)\//)) {
            globalLinks[1] = '<a href="' + linkdata[item] + '" class="list-group-item">Type Aliases</a>';
            selectdata[3].children.push({ id: item, text: item });
        } else if (linkdata[item].match(/\/(func)\//)) {
            collapseAreas[3] += '<a href="' + linkdata[item] + '" class="list-group-item">' + item + '</a>';
            selectdata[3].children.push({ id: item, text: item });
        }
    }
    $('.select2').select2({ placeholder: "Search", minimumInputLength: 1, formatInputTooShort: '', data: selectdata})
                .on("change", function(e) {
                    if (linkdata[e.val]) {
                        window.location.href = linkdata[e.val];
                    }
                });

    $('#collapseTypes').html(collapseAreas[0]);
    $('#collapseProtocols').html(collapseAreas[1]);
    $('#collapseOperators').html(collapseAreas[2]);
    $('#collapseGlobals').html(globalLinks[0] + globalLinks[1] + '<span class="subnav-header list-group-item">Functions</span>' + collapseAreas[3]);
})
