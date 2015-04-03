require 'sinatra/base'
require 'mustache/sinatra'

class Server < Sinatra::Base
  register Mustache::Sinatra

  set :root, File.join(__dir__, 'server')

  set :mustache, {
    views: File.join(root, 'views'),
    templates: File.join(root, 'templates')
  }

  set :entries, proc { [ ] }

  get '/' do
    @entries = settings.entries
    mustache :index
  end

  get '/:year-:month' do |year, month|
    @date = Date.new year.to_i, month.to_i
    @entries = settings.entries

    mustache :month
  end
end

require_relative 'server/views/layout'
require_relative 'server/views/index'
