$:.unshift 'rack-openid/lib'
require 'sinatra/base'
require 'ruby-debug'
require 'rack/openid'
require 'activerecord'
require 'open_fun'

use Rack::Lint
use Rack::ShowExceptions
use Rack::Static, :urls => %w|/images /css|, :root => "public"
use Rack::Session::Cookie
use Rack::OpenID

run OpenFun.new
