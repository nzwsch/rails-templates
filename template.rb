# Usage: rails new app_name -m template.rb

# def rails_version
#   @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
# end
# def rspec_version
#   @rspec_version ||= Gem::Version.new(RSpec::Rails::Version::STRING)
# end

# 1. Add .editorconfig file
file ".editorconfig", <<~CODE
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
CODE

# 2. Remove unnecessary files
[
  ".rubocop.yml",
  "public/apple-touch-icon-precomposed.png",
  "vendor/.keep",
].each do |file|
  run "rm #{file}" if File.exist?(file)
end

# 3. Add .rubocop.yml file
file ".rubocop.yml", <<~CODE
inherit_gem:
  rubocop-rails-omakase: rubocop.yml
  rubocop-rspec: config/default.yml

require:
  - rubocop-rspec

Style/PercentLiteralDelimiters:
  PreferredDelimiters:
    "%w": "()"
CODE

# 4. Add .rufo file
file ".rufo", <<~CODE
excludes [db/schema.rb]
CODE

# 5. Add Procfile
file "Procfile", <<~CODE
web: ./bin/rails s
CODE

# 6. Update environment files
environment "config.generators.view_specs = false"
environment "config.assume_ssl = true", env: "production"
environment "config.active_job.queue_adapter = :test", env: "test"

# 7. Add test gems to Gemfile
gem_group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "shoulda-matchers", "~> 6.2"
  gem "webmock", "~> 3.23"
end

# 8. Add rubocop-rails-omakase gem and rubocop-rspec gem to Gemfile
gem_group :development do
  gem "rubocop-rails-omakase", "~> 1.0.0", require: false
  gem "rubocop-rspec", "~> 3.0.4", require: false
  gem "brakeman", require: false
end

# 9. Make directory for spec/support
run "mkdir -p spec/support"

# 10. Add spec/support/factory_bot.rb file
file "spec/support/factory_bot.rb", <<~CODE
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
CODE

# 11. Add spec/support/shoulda_matchers.rb file
file "spec/support/shoulda_matchers.rb", <<~CODE
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
CODE

# 12. Execute rspec:install
after_bundle do
  generate "rspec:install"

  inside("spec") do
    line = '# Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }'
    gsub_file "rails_helper.rb", line, line.sub("# ", "")

    line = "# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }"
    gsub_file "rails_helper.rb", line, line.sub("# ", "")

    insert_into_file "rails_helper.rb", after: "require 'rspec/rails'\n" do
      "require 'webmock/rspec'\n"
    end
  end
end
