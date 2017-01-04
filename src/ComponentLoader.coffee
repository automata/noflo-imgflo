request = require 'request'
noflo = require 'noflo'
imgflo = require 'imgflo-url'
defaultConfig = require('./config').config

getComponentForGraph = (config, graphName, graph) ->
  return (metadata) ->
    c = new noflo.Component
    paramPorts = []
    for name, def of graph.inports
      safeName = name.replace /-/g, ''
      c.inPorts.add safeName
      c.inPorts.ports[safeName].imgfloPort = name
      paramPorts.push safeName unless safeName is 'input'
    for name, def of graph.outports
      safeName = name.replace /-/g, ''
      c.outPorts.add safeName
      c.outPorts.ports[safeName].imgfloPort = name

    noflo.helpers.WirePattern c,
      in: 'input'
      out: 'output'
      forwardGroups: true
      params: paramPorts
    , (data, groups, out) ->
      params = JSON.parse JSON.stringify c.params
      params.input = data
      out.send imgflo config, graphName, params, 'png'

    return c

getGraphsList = (config, callback) ->
  server = config.server
  url = "#{server}graphs"
  req = request
    url: url
    timeout: 10000

  request.get url, (err, resp, body) ->
    return callback err if err
    callback JSON.parse(body).graphs

module.exports = (loader, config, done) ->
  if typeof config == 'function'
    done = config
    config = defaultConfig
  getGraphsList config, (graphs) ->
    for name, def of graphs
      bound = getComponentForGraph config, name, def
      loader.registerComponent 'imgflo', name, bound
    do done
