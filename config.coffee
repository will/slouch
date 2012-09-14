module.exports =
  port: process.env.PORT || 3000
  database_url: process.env.DATABASE_URL || 'postgres:///slouch'
  google:
    clientId: process.env.GOOGLE_CLIENT_ID
    clientSecret: process.env.GOOGLE_CLIENT_SECRET

