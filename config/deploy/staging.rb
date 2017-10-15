set :stage, :production

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server '34.215.24.136', user: 'ubuntu', roles: [:web, :app, :db], primary: true
