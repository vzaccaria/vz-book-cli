

_module = ->

    y        = require('js-yaml')
    moment   = require('moment')
    _        = require('underscore')
    _.str    = require('underscore.string');

    _.mixin(_.str.exports());
    _.str.include('Underscore.string', 'string');
    debug = require('debug')('parsey')


    parse = (file) ->
        yaml = ""
        content = ""
        is-yaml = false
        for l in _.lines(file)
            if is-yaml
                if l == /^---/ or l == /^\.\.\.$/
                    is-yaml := false
                else
                    yaml := yaml + "\n" + l
            else
                if (l == /^---/ and yaml == "")
                    is-yaml := true
                    yaml := yaml + "\n" + l
                else
                    content := content + "\n" + l

        data            = {}
        debug(yaml)
        metadata        = y.safeLoad(yaml)
        data.metadata   = metadata
        data.md-content = content
        return data
       
          
    iface = { 
        parse: parse
    }
  
    return iface
 
module.exports = _module()

