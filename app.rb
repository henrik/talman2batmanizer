# encoding: utf-8

require "rubygems"
require "bundler"
Bundler.require :default, (ENV['RACK_ENV'] || "development").to_sym
require "net/http"
require "./caching"

HOST = "www.riksdagen.se"
START_PATH = "/sv/Sa-funkar-riksdagen/Talmannen/"

get "/" do
  proxy_get START_PATH
end

get "*" do
  proxy_get request.fullpath
end

post "*" do
  proxy_post request.fullpath, params
end


def make_uri(path)
  URI.parse("http://#{HOST}" + debatmanize(path))
end

def proxy_get(path)
  uri = make_uri(path)
  proxy_response Net::HTTP.get_response(uri)
end

def proxy_post(path, params)
  uri = make_uri(path)
  proxy_response Net::HTTP.post_form(uri, params)
end


def proxy_response(response)
  ct = response['content-type']

  content_type ct
  cache_control :public, max_age: 600  # 10 mins.

  body = response.body.force_encoding("UTF-8")

  return body unless ct.include?("text/html")

  # There are some absolute links in there.
  body.gsub!(HOST, request.host_with_port)

  batmanize body
end

def batmanize(text)
  text.gsub(/\b(t)(a)(l)(m(a|ä|&#228;)n)/i) {
    "#{$1.tr 'Tt', 'Bb'}#$2#{$3.tr 'Ll', 'Tt'}#$4"
  }
end

def debatmanize(text)
  text.gsub(/\b(b)(a)(t)(m[aä]n)/i) {
    "#{$1.tr 'Bb', 'Tt'}#$2#{$3.tr 'Tt', 'Ll'}#$4"
  }
end
