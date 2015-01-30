noflo = require 'noflo'
imgflo = require 'imgflo-url'
request = require 'request'

runGraph = (graph) ->
  config =
    server: 'https://imgflo.herokuapp.com/'
    key: process.env.IMGFLO_KEY
    secret: process.env.IMGFLO_SECRET

  params =
    input: 'https://pbs.twimg.com/media/BlM0d2-CcAAT9ic.jpg:large'
    color1: '#0A2A2F'
    color2: '#FDE7A0'
    srgb: true

  url = imgflo config, graph, params, 'png'
  console.log 'url', url

  req = request
    url: url
    timeout: 10000

  req.on 'response', (resp) ->
    console.log 'response', resp
    return if resp.statusCode is 200
      error = new Error "#{url} responded with #{resp.statusCode}"
      error.url = url

getGraphsList = (callback) ->
  server = 'https://imgflo.herokuapp.com/'

  url = "#{server}demo"

  console.log 'url', url

  req = request
    url: url
    timeout: 10000

  request.get 'https://imgflo.herokuapp.com/demo', (err, resp, body) ->
    callback JSON.parse(body).graphs

#runGraph 'gradientmap'

# getGraphsList (graphs) ->
#   console.log graphs

exports.getComponent = ->
  c = new noflo.Component

  # Define a meaningful icon for component from http://fontawesome.io/icons/
  c.icon = 'cog'

  # Provide a description on component usage
  c.description = 'do X'

  # Add input ports
  c.inPorts.add 'in',
    datatype: 'string'
    process: (event, payload) ->
      # What to do when port receives a packet
      return unless event is 'data'
      requestGraphList()

      c.outPorts.out.send payload

  # Add output ports
  c.outPorts.add 'out',
    datatype: 'string'

  # Finally return the component instance
  c
