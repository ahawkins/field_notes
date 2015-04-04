require 'redcarpet'

class MarkdownGenerator
  class Render < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants

    def postprocess(doc)
      super.tap do |html|
        bad_links = html.scan /\[[^\[\]]+\]\[([^\[\]]+)/
        if bad_links.any?
          links = bad_links.compact.join ','
          message = "Unmatched link names: #{links}"
          fail message
        end
      end
    end
  end

  def initialize
    @renderer = Redcarpet::Markdown.new(Render, {
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      highlight: true
    })
  end

  def html(text)
    @renderer.render text
  end
end
