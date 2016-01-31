/* eslint quotes: [0], strict: [0] */
var {
    $d, $o, $f
    // $r.stdin() -> Promise  ;; to read from stdin
} = require('zaccaria-cli')

var getOptions = doc => {
    "use strict"
    var o = $d(doc)
    var help = $o('-h', '--help', false, o)
    return {
        help
    }
}

var main = () => {
    $f.readLocal('docs/usage.md').then(it => {
        var {
            help
        } = getOptions(it);
        if (help) {
            console.log(it)
        }
    })
}

main()
