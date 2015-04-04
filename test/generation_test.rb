require_relative 'test_helper'

class GenerationTest < MiniTest::Test
  def test_fails_if_files_does_not_lead_with_date
    Dir.mktmpdir do |dir|
      File.open File.join(dir, 'junk.md'), 'w' do |entry|
        entry.write outdent(<<-EOF)
        ---
        tag: note
        ---

        Free form content
        EOF
      end

      error = assert_raises RuntimeError do
        FieldNotes.generate dir
      end

      assert_match /format/, error.message, 'Error message not descriptive'
    end
  end

  def test_ignores_non_markdown_files
    Dir.mktmpdir do |dir|
      File.open File.join(dir, 'junk.text'), 'w' do |entry|
        entry.puts 'Testing'
      end

      FieldNotes.generate(dir).tap do |result|
        assert_empty result
      end
    end
  end

  def test_generation_from_files
    Dir.mktmpdir do |dir|
      File.open File.join(dir, '2015-01-02-test.md'), 'w' do |entry|
        entry.write outdent(<<-EOF)
        ---
        tag: note
        ---
        Free form content
        EOF
      end

      entries = FieldNotes.generate dir
      assert_equal 1, entries.count

      entries.first.tap do |entry|
        assert_equal 'note', entry.tag
        assert_equal 'Free form content', entry.content
        assert_equal Date.new(2015, 01, 02), entry.date
      end
    end
  end

  def test_provides_default_tag
    Dir.mktmpdir do |dir|
      File.open File.join(dir, '2015-01-02-test.md'), 'w' do |entry|
        entry.write outdent(<<-EOF)
        Free form content
        EOF
      end

      entries = FieldNotes.generate dir
      assert_equal 1, entries.count

      entries.first.tap do |entry|
        assert_equal 'other', entry.tag
        assert_match /Free form content/, entry.content
        assert_equal Date.new(2015, 01, 02), entry.date
      end
    end
  end

  def test_generate_recurses_into_subdirectories
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p File.join(dir, 'foo', 'bar', 'baz')

      File.open File.join(dir, 'foo', 'bar', 'baz', '2015-01-02-test.md'), 'w' do |entry|
        entry.write outdent(<<-EOF)
        ---
        tag: note
        ---

        Free form content
        EOF
      end

      entries = FieldNotes.generate dir
      assert_equal 1, entries.count

      entries.first.tap do |entry|
        assert_equal 'note', entry.tag
        assert_match /Free form content/, entry.content
        assert_equal Date.new(2015, 01, 02), entry.date
      end
    end
  end

  private

  def outdent(text)
    indent = text.scan(/^[ \t]*(?=\S)/).min.size
    text.gsub(/^[ \t]{#{indent}}/, '')
  end
end
