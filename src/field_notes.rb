require 'yaml'
require 'forwardable'

class FieldNotes
  Entry = Struct.new :date, :content, :tag do
    extend Forwardable

    def_delegators :date, :year, :month
  end

  class << self
    def generate(directory)
      Dir[File.join(directory, '**', '*.md')].map do |file|
        Entry.new.tap do |entry|
          meta = YAML.load_file file
          parts = File.basename(file, '.md').match(/\A(\d{4})-(\d{2})-(\d{2})-.+\z/)

          fail RuntimeError, "#{File.basename(file)} does not follow format" if parts.nil?

          entry.date = Date.new *parts.captures.map(&:to_i)
          entry.tag = meta.is_a?(Hash) ? meta.fetch('tag') : 'other'
          entry.content = File.read(file).gsub(/\A---.+---/m, '').strip
        end
      end
    end
  end
end
