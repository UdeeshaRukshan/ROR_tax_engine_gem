# frozen_string_literal: true

require_relative "lib/tax_engine/version"

Gem::Specification.new do |spec|
  spec.name = "tax_calculator_gem"
  spec.version = TaxCalculatorGem::VERSION
  spec.authors = ["udeesharukshan"]
  spec.email = ["udeeshagamage12@gmail.com"]

  spec.summary = "A Ruby gem for calculating US sales tax with live API rate lookup and caching."
  spec.description = "TaxCalculatorGem fetches live sales tax rates from the Washington State DOR API, supports manual rate overrides, per-item cart calculation, and pluggable in-memory or Redis caching."
  spec.homepage = "https://github.com/udeesharukshan/tax_calculator_gem"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/udeesharukshan/tax_calculator_gem"
  spec.metadata["changelog_uri"] = "https://github.com/udeesharukshan/tax_calculator_gem/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "nokogiri", "~> 1.16"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
