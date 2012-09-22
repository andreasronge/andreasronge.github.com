NEO4J_VERSION = "2.0.1"

gem_group :development, :test do
  gem "rspec-rails"
end

gem "neo4j", ">= #{NEO4J_VERSION}"

gsub_file 'config/application.rb', "require 'rails/all'", <<END
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'rails/test_unit/railtie'
require 'will_paginate/railtie'
require 'neo4j'
END

generator = %q[

    # Enable Neo4j generators, e.g:  rails generate model Admin --parent User
    config.generators do |g|
      g.orm             :neo4j
      g.test_framework  :rspec, :fixture => false
    end

    # Configure where the neo4j database should exist
    config.neo4j.storage_path = "#{config.root}/db/neo4j-#{Rails.env}"
]

inject_into_file 'config/application.rb', generator, :after => '[:password]'
