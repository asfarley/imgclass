# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = User.create!  :email => 'admin@imgclass.com', :password => 'password', :password_confirmation => 'password', :roles => "admin"
user = User.create!  :email => 'worker@imgclass.com', :password => 'password', :password_confirmation => 'password', :roles => "worker"
