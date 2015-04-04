ENV['RACK_ENV'] = 'test'

root = File.expand_path '../../', __FILE__
require "#{root}/boot"

require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'fileutils'
require 'capybara'

class MiniTest::Test
  private

  def outdent(text)
    indent = text.scan(/^[ \t]*(?=\S)/).min.size
    text.gsub(/^[ \t]{#{indent}}/, '')
  end
end
