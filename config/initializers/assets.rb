# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( imgclass.css )
Rails.application.config.assets.precompile += %w( image_labels.js )
Rails.application.config.assets.precompile += %w( image_label_maker.js )
Rails.application.config.assets.precompile += %w( bb.js )
Rails.application.config.assets.precompile += %w( coverage.js )
Rails.application.config.assets.precompile += %w( 3f382c6f.png )
