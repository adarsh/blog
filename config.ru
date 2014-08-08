require 'rack'
require 'rack/contrib/try_static'

use Rack::Deflater

use Rack::TryStatic,
  root: 'build',
  urls: %w[/],
  try: ['.html', 'index.html', '/index.html']

run proc { [404, { 'Content-Type' => 'text/html' }, ['Page not found']] }
