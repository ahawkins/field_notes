ENV['RACK_ENV'] = 'test'

root = File.expand_path '../../', __FILE__
require "#{root}/boot"

require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
