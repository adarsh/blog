activate :blog do |blog|
  blog.layout = 'article'
  blog.new_article_template = 'source/new_article_template.html.erb'
  blog.permalink = ":title"
  blog.sources = "articles/{year}/{title}"

  blog.custom_collections = {
    category: {
      link: '/categories/{category}.html',
      template: '/category.html'
    }
  }
end

set :css_dir, 'stylesheets'
set :haml, ugly: true
set :images_dir, 'images'
set :js_dir, 'javascripts'
set :markdown, fenced_code_blocks: true, smartypants: true
set :markdown_engine, :redcarpet
set :relative_links, true
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

activate :automatic_alt_tags
activate :automatic_image_sizes
activate :directory_indexes
activate :livereload
activate :neat
activate :syntax

activate :google_analytics do |ga|
  ga.tracking_id = 'UA-1322480-9'
end

page '/feed.xml', layout: false
page '/sitemap.xml', layout: false
