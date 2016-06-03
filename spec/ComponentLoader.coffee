noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai' unless chai
  ComponentLoader = require '../src/ComponentLoader'
else
  ComponentLoader = require 'noflo-runtime/src/ComponentLoader'

baseDir = '../src/ComponentLoader'

config =
    key: 'key'
    secret: 'secret'
    server: 'https://imgflo.herokuapp.com/'

describe 'ComponentLoader', ->

  it 'should export a function', ->
    chai.expect(ComponentLoader).to.be.a 'function'

  describe 'should initialize', ->
    loader = new noflo.ComponentLoader baseDir

    imgfloGraph = 'imgflo/passthrough'

    it 'should list imgflo graphs as components', (done) ->
      @timeout 5000
      loader.listComponents (err) ->
        return done err if err
        # Initialized
        ComponentLoader loader, config, (err) ->
          loader.listComponents (err, components) ->
            return done err if err
            chai.expect(components[imgfloGraph]?).to.be.true
            done()

    it 'should load a graph and produce the right results', (done) ->
      @timeout 5000
      imageUrl = 'http://bergie.iki.fi/files/flowhub-promo.jpg'

      component = loader.load imgfloGraph, (err, instance) ->
        chai.expect(err).to.equal null
        chai.expect(instance).to.not.equal null
        chai.expect(instance).to.be.instanceOf noflo.Component

        ins = noflo.internalSocket.createSocket()
        width = noflo.internalSocket.createSocket()
        height = noflo.internalSocket.createSocket()
        out = noflo.internalSocket.createSocket()
        instance.inPorts.input.attach ins
        instance.inPorts.width.attach width
        instance.inPorts.height.attach height
        instance.outPorts.output.attach out

        groups = []
        out.on 'begingroup', (group) ->
          groups.push group
        out.on 'data', (data) ->
          chai.expect(data).to.contain 'width'
          chai.expect(data).to.contain 'height'
          done()
        out.on 'endgroup', () ->
          groups.pop()
        
        ins.beginGroup imageUrl
        width.send 300
        height.send 200
        ins.send imageUrl
        ins.endGroup()
        ins.disconnect()
