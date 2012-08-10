require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym

require "net/http"


get "/" do
  proxy_get("/Dokument-Lagar/Kammaren/Protokoll/")
end

get "*" do
  proxy_get request.fullpath
end

post "*" do
  proxy_post request.fullpath, params
end


def make_uri(path)
  URI.parse("http://www.riksdagen.se" + debatmanize(path))
end

def proxy_get(path)
  uri = make_uri(path)
  response = Net::HTTP.get_response(uri)

  content_type response['content-type']
  batmanize response.body
end

def proxy_post(path, params)
  uri = make_uri(path)
  response = Net::HTTP.post_form(uri, params)

  content_type response['content-type']
  batmanize response.body
end

def batmanize(text)
  text.gsub(/\b(t)(a)(l)(man)/i) {
    "#{$1.tr 'Tt', 'Bb'}#$2#{$3.tr 'Ll', 'Tt'}#$4"
  }
end

def debatmanize(text)
  text.gsub(/\b(b)(a)(t)(man)/i) {
    "#{$1.tr 'Bb', 'Tt'}#$2#{$3.tr 'Tt', 'Ll'}#$4"
  }
end
