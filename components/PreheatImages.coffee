noflo = require 'noflo'
superagent = require 'superagent'

preheat = (images, cached, callback) ->
  unless images.length
    callback null, cached
    return

  image = images.shift()
  req = superagent.post image
  req.redirects 0
  req.end (err, res) ->
    # err is ignored, since Superagent considers 301 an error...
    location = res.header.location
    unless location
      return callback new Error "ImgFlo request #{image} resulted in #{res.statusCode} instead of location"

    cached.push location
    preheat images, cached, callback

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Pre-heat imgflo cache for images'
  c.icon = 'file-archive-o'

  c.inPorts.add 'in',
    datatype: 'array'
  c.outPorts.add 'out',
    datatype: 'array'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'out'
    async: true
    forwardGroups: true
  , (data, groups, out, callback) ->
    preheat data, [], (err, cached) ->
      return callback err if err
      out.send cached
      do callback

  c

