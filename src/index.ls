{docopt} = require('docopt')
bb       = require('bluebird')
fs       = bb.promisifyAll(require('fs'))
sh       = bb.promisifyAll(require('shelljs'))
glob     = require('glob')
_ = require('lodash')
Promise  = bb
{parse}  = require('./lib/parsey')

require! 'fs'

doc = """
Usage:
    book-cli FILE...
    book-cli -h | --help

Argument:
    FILE                One or more files to be reordered
"""

get-option = (a, b, def, o) ->
    if not o[a] and not o[b]
        return def
    else
        return o[b]

o = docopt(doc)


subst = (text) ->
    text = text.replace(/begin{quote}/g, 'begin{em}' )
    text = text.replace(/end{quote}/g, 'end{em}\\vspace{.8em}')
    ## text = text.replace(/footnote{/g, 'marginnote{')
    ## text = text.replace(/begin{figure}/g, 'begin{marginfigure}')
    ## text = text.replace(/end{figure}/g, 'end{marginfigure}')
    ## text = text.replace(/\[htbp\]/g, '')
    return text

genLatex = (content) ->
    return new Promise (resolve) ->
        c = sh.exec 'pandoc -t latex', {+async, +silent}, (code, data) ->
            data = subst(data)
            resolve(data)
        c.stdin.write(content)
        c.stdin.end()

stars = (d) ->
    '$' + ([ '\\star' for i in [ 1 to d ] ] * '') + '$'

render = (metadata, content) ->
    let @=metadata
        """
            \\newpage
            \\section{#{@title}}
            \\textbf{\\sffamily Difficoltà}: #{stars @difficulty} \\hspace{1.5em} \\textbf{\\sffamily Linguaggio}: {\\sffamily #{@language}} \\hspace{1.5em} \\textbf{\\sffamily Argomenti}: {\\sffamily #{@tags * ' '} } \\\\

            \\vspace{1.3em}


            #content
        """

filename      = get-option('-f' , '--file'     , '/dev/stdin'  , o)

genLatexObject = (markdown) ->
    parsed = parse(markdown)
    genLatex(parsed.md-content).then ->
        parsed.latex-content = render(parsed.metadata, it)
        return parsed

genChapters = (data) ->
    for k,v of data
        s =
            """

            \\chapter{#k}

            #{[ d.latex-content for d in v ] * '\n\n'}

            """
        console.log s


files = o['FILE']
bb.all([ fs.readFileAsync(f, 'utf-8') for f in files]).then (data) ->
    bb.all([ genLatexObject(d) for d in data ]).then (data) ->
        data = _.groupBy(data, (.metadata.language) )
        for k,v of data
            data[k] = _.sortBy(v, (.metadata.difficulty))

        genChapters(data)
