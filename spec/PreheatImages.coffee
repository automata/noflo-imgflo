chai = require 'chai'
noflo = require 'noflo'
path = require 'path'
baseDir = path.resolve __dirname, '../'

describe 'Cache pre-heating', ->
  c = null
  ins = null
  out = null
  error = null
  before (done) ->
    @timeout 8000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'imgflo/PreheatImages', (err, instance) ->
      return done err if err
      c = instance
      done()
  beforeEach ->
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    error = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out
    c.outPorts.error.attach error
  afterEach ->
    c.inPorts.in.detach ins
    c.outPorts.out.detach out
    c.outPorts.error.detach error
    ins = null
    out = null
    error = null

  describe 'pre-heating an ImgFlo image', ->
    it 'should return a correct URL', (done) ->
      error.on 'data', done
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data.length).to.equal 1
        chai.expect(data[0]).to.be.a 'string'
        done()
      ins.send [
        'https://imgflo.herokuapp.com/graph/vahj1ThiexotieMo/fbd8c59fcaa79eb27f2759b7fef520c9/passthrough.jpg?input=https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fcdn.thegrid.io%2Fassets%2Fimages%2Fpurus-02.jpg&width=1276&height=954'
      ]

