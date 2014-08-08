require 'date'
require 'dotenv/tasks'

desc 'Build project and compile assets'
namespace :assets do
  task :precompile do
    sh 'middleman build'
  end
end

desc 'Create a new post'
task :new do
  STDOUT.print 'Please enter the post title: '
  title = STDIN.gets.strip
  abort('You must provide a title') if title.empty?

  slug = title.downcase.gsub(/[^0-9a-z]+/i, '-')
  STDOUT.print "Would you like to use `#{slug}` as the slug (y/n)? "
  slug_answer = STDIN.gets.strip

  if slug_answer == 'n'
    STDOUT.print 'Please enter a slug: '
    slug = STDIN.gets.strip
    abort('You must provide a slug') if slug.empty?
  end

  filename = "source/articles/#{slug}.md"

  if File.exist?(filename)
    abort("file #{filename} name already exists")
  end

  author = `git config --get user.name`
  date = Date.today.to_s

  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: #{title}"
    post.puts "date: #{date}"
    post.puts "author: #{author}"
    post.puts "description:"
    post.puts "category:"
    post.puts "---"
  end

  puts "Created new post at #{filename}"
end

desc 'Deploy blog to Heroku'
task :deploy => :dotenv do
  puts 'Deploying to Heroku'
  `git push heroku master`

  puts 'Purging edge-cache'
  api_key = ENV['FASTLY_KEY']
  site_key = ENV['FASTLY_SITE_KEY']
  `curl -X POST -H 'Fastly-Key: #{api_key}' https://api.fastly.com/service/#{site_key}/purge_all`
end
