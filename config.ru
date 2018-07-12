require "rack"
require "rack/contrib/try_static"
require 'rack/ssl'

# Enable proper HEAD responses
use Rack::Head

# Add basic auth if configured
if ENV["HTTP_USER"] && ENV["HTTP_PASSWORD"]
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [ENV["HTTP_USER"], ENV["HTTP_PASSWORD"]]
  end
end

# Attempt to serve static HTML files
use Rack::TryStatic,
    :root => "build",
    :urls => %w[/],
    :try => ['.html', 'index.html', '/index.html']

# Serve a 404 page if all else fails
run lambda { |env|
  [
    404,
    {
      "Content-Type" => "text/html",
      "Cache-Control" => "public, max-age=60"
    },
    File.open("build/404/index.html", File::RDONLY)
  ]
}
# Force SSL
unless ENV["DEV_ENV"]
  use Rack::SSL
end
