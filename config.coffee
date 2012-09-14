module.exports =
  port: process.env.PORT || 3000
  database_url: process.env.DATABASE_URL || 'postgres:///slouch'
  env: process.env.ENV || 'development'
  secret: process.env.SECUREKEY_GOLD_KEY || 'foo'
  google:
    clientId: process.env.GOOGLE_CLIENT_ID
    clientSecret: process.env.GOOGLE_CLIENT_SECRET

