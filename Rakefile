require 'colorize'
require 'erb'
require 'open3'
require 'yaml'

if RUBY_VERSION >= '1.9'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

# ===================================================
# Linting Tasks
# ===================================================

desc 'Check syntax of various file types'
task :lint do
  puts 'Begin linting source code'.cyan
  %i[rubocop erb lono yaml].each do |action|
    Rake::Task[action].invoke
  end
  puts 'Finsihed linting source code'.cyan
end

desc 'Check syntax of .erb files'
task :erb do
  sh 'rails-erb-lint check -e'
end

desc 'Check syntax of .yml files'
task :yaml do
  Dir['**/*.yml', '**/*.yaml'].each do |file|
    sh "yaml-lint #{file}"
  end
end

desc 'Generate cloudformtion template with lono'
task :lono do
  sh 'lono generate'
end

# ===================================================
# Main Tasks
# ===================================================

task :install do
  [:lint].each do |action|
    Rake::Task[action].invoke
  end
end

task :deploy do
  [:install].each do |action|
    Rake::Task[action].invoke
  end
  Dir['form_cloud.sh'].each do |file|
    sh "`pwd`/#{file} `pwd`"
  end
end

# task :deploy do
