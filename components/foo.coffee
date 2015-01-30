noflo = require 'noflo'
imgflo = require 'imgflo-url'
request = require 'request'
console.log 'hey'
requestGraphList = () ->
  config =
    server: 'https://imgflo.herokuapp.com/'
    key: process.env.IMGFLO_KEY
    secret: process.env.IMGFLO_SECRET

  params =
    input: 'https://pbs.twimg.com/media/BlM0d2-CcAAT9ic.jpg:large'
    color1: '#0A2A2F'
    color2: '#FDE7A0'
    srgb: true

  url = imgflo config, 'gradientmap', params, 'png'
  console.log 'url', url

  request url, (error, response, body) ->
    console.log 'hahaha'

requestGraphList()