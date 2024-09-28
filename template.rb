# Description: This script is for Rails 7.2.0.

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

# 2. Add rubocop-rails-omakase gem and rubocop-rspec gem to Gemfile
gem_group :development do
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
end

# Remove .rubocop.yml file if it exists
if File.exist?(".rubocop.yml")
  run "rm .rubocop.yml"
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

# 4. Add rspec-rails gem to Gemfile
gem_group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "shoulda-matchers", "~> 6.2"
  gem "webmock", "~> 3.23"
end

# 5. Make directory for spec/support
run "mkdir -p spec/support"

# 6. Add spec/support/factory_bot.rb file
file "spec/support/factory_bot.rb", <<~CODE
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
CODE

# 7. Add spec/support/shoulda_matchers.rb file
file "spec/support/shoulda_matchers.rb", <<~CODE
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
CODE

# 8. Execute rspec:install
after_bundle do
  generate "rspec:install"
end
