activate :blog do |blog|
  blog.permalink = ":title"
  blog.sources = "articles/:title"
  blog.layout = 'article'
end

set :css_dir, 'stylesheets'
set :haml, ugly: true
set :images_dir, 'images'
set :js_dir, 'javascripts'
set :markdown, fenced_code_blocks: true, smartypants: true
set :markdown_engine, :redcarpet
set :site_name, 'Adarsh Pandit'
set :trailing_slash, false

configure :build do
  activate :asset_hash
  activate :minify_css
  activate :minify_javascript
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
  deploy.remote  = 'git@github.com:adarsh/adarsh.github.io.git'
  deploy.branch  = 'master'
end

activate :automatic_image_sizes
activate :directory_indexes
activate :neat
activate :syntax
