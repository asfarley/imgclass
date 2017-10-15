set :stage, :production

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server '34.215.24.136', user: 'ubuntu', roles: %w{app web db}


# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

role :app, %w{ubuntu@34.215.24.136}
role :web, %w{ubuntu@34.215.24.136}
role :db,  %w{ubuntu@34.215.24.136}
