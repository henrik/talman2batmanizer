require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym

require "open-uri"


get "/" do
  proxy_get "/Dokument-Lagar/Kammaren/Protokoll/"
end

get "*" do
  proxy_get request.fullpath
end

post "*" do
  proxy_post request.fullpath, params
end


def make_uri(path)
  URI.parse("http://www.riksdagen.se" + path)
end

def proxy_get(path)
  # open-uri, follows redirects etc cleverly.
  make_uri(path).read
end

def proxy_post(path, params)
  uri = make_uri(path)
  response = Net::HTTP.post_form(uri, params)
  response.body
end
