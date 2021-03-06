require 'bundler/setup'

require_relative 'src/field_notes'
require_relative 'src/markdown_generator'
require_relative 'src/server'

Server.set :entries, FieldNotes.generate(File.join(__dir__, 'notes'))
Server.set :markdown_generator, MarkdownGenerator.new
