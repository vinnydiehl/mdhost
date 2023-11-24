# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name = "mdhost"
  gem.version = File.read(File.expand_path("VERSION", __dir__)).strip

  gem.author = "Vinny Diehl"
  gem.email = "vinny.diehl@gmail.com"
  gem.homepage = "https://github.com/vinnydiehl/mdhost"
  gem.metadata["rubygems_mfa_required"] = "true"

  gem.license = "MIT"

  gem.summary = "Generate Markdown eshost tables"
  gem.description = "Runs eshost in table mode, copying a Markdown version " \
                    "of the table to your clipboard."

  gem.bindir = "bin"
  gem.executables = %w[mdhost]
  gem.files = `git ls-files -z`.split "\x0"

  gem.add_dependency "clipboard", "~> 1.1"
  gem.add_dependency "optimist", "~> 3.1"

  gem.add_development_dependency "rubocop", "~> 1.54"
end
