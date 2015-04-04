require_relative 'test_helper'
require 'nokogiri'

class MarkdownGeneratorTest < MiniTest::Test
  attr_reader :generator

  def setup
    @generator = MarkdownGenerator.new
  end

  def test_fails_if_referenced_link_incorrect
    error = assert_raises RuntimeError do
      generator.html outdent(<<-EOF)
      Something [Link Text][unreferenced-link]
      EOF
    end

    assert_match /unreferenced-link/, error.message, 'Error message not descriptive'
  end

  def test_implements_highlight_syntax
    html = generator.html outdent(<<-EOF)
    Something ==important==
    EOF

    document = Nokogiri.HTML html
    assert_equal 'important', document.at_xpath('//mark').text
  end

  def test_implements_fenced_code_blocks
    html = generator.html outdent(<<-EOF)
    Something something

    ```foo-lang
    foo-code
    ```
    EOF

    document = Nokogiri.HTML html
    code_element = document.at_xpath '//code[@class="foo-lang"]'
    assert code_element, 'Missing <code>'
    assert_equal 'foo-code', code_element.text.strip
  end
end
