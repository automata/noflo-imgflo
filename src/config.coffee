config =
  server: process.env.IMGFLO_SERVER or 'https://imgflo.herokuapp.com/'
  key: process.env.IMGFLO_KEY
  secret: process.env.IMGFLO_SECRET

exports.config = config
