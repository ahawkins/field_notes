require_relative 'test_helper'
require 'fileutils'
require 'capybara'

class ViewingTest < MiniTest::Test
  class GUI
    include Capybara::DSL

    def initialize
      Server.set :entries, [ ]
      Capybara.app = Server
    end

    def data=(entries)
      Server.set :entries, entries
    end

    def open_home_page
      @current_page = :home
      visit '/'
    end

    def click(date)
      click_on date
      @current_page = :month
    end

    def blank?
      case @current_page
      when :home
        page.has_selector?(:css, '#no-field-notes')
      else
        fail "#{page} cannot be blank"
      end
    end

    def date?(date)
      case @current_page
      when :home
        all(:css, 'li.date').any? { |li| li.text == date }
      else
        false
      end
    end

    def section?(name)
      case @current_page
      when :month
        all(:css, 'h2.tag').any? { |s| s.text == name }
      else
        nil
      end
    end

    def says?(text)
      page.has_content? text
    end

    def open_previous_note
      find(:css, '.previous a').click
    end

    def previous_notes?
      page.has_selector?('.previous a')
    end

    def open_next_note
      find(:css, '.next a').click
    end

    def next_notes?
      page.has_selector? '.next a'
    end

    def pagination?
      page.has_selector? '.pagination'
    end
  end

  attr_reader :gui, :today

  def setup
    @gui = GUI.new
    @today = Date.today
  end

  def test_displays_message_when_no_field_notes
    gui.open_home_page

    assert gui.blank?, "Empty case not handled"
  end

  def test_groups_notes_into_month
    gui.data = [
      FieldNotes::Entry.new(Date.new(2010,01,02), 'text', 'testing'),
      FieldNotes::Entry.new(Date.new(2012,01,02), 'text', 'testing')
    ]

    gui.open_home_page

    assert gui.date?('January 2010'), 'Dates incorrect'
    assert gui.date?('January 2012'), 'Dates incorrect'
  end

  def test_entries_are_grouped_by_tag_on_monthly_view
    note_a = FieldNotes::Entry.new today, 'Note A', 'foo'
    note_b = FieldNotes::Entry.new today, 'Note B', 'bar'

    gui.data = [ note_a, note_b ]

    gui.open_home_page

    gui.click today.strftime("%B %Y")

    assert gui.section?(note_a.tag), 'Sections incorrect'
    assert gui.section?(note_b.tag), 'Sections incorrect'

    assert gui.says?(note_a.content), 'Note not shown'
    assert gui.says?(note_b.content), 'Note not shown'
  end

  def test_displays_previous_link_if_available
    note_a = FieldNotes::Entry.new today - 31, 'Note A', 'foo'
    note_b = FieldNotes::Entry.new today, 'Note B', 'bar'
    refute_equal note_a.month, note_b.month, 'Precondition failed'

    gui.data = [ note_a, note_b ]

    gui.open_home_page

    gui.click today.strftime("%B %Y")

    refute gui.says?(note_a.content), 'Initial note incorrect'
    assert gui.says?(note_b.content), 'Initial note incorrect'

    gui.open_previous_note

    assert gui.says?(note_a.content), 'Previous note incorrect'
    refute gui.says?(note_b.content), 'Previous note incorrect'
    refute gui.previous_notes?, 'Previous link incorrect'
  end

  def test_displays_next_link_if_available
    note_a = FieldNotes::Entry.new today + 31, 'Note A', 'foo'
    note_b = FieldNotes::Entry.new today, 'Note B', 'bar'
    refute_equal note_a.month, note_b.month, 'Precondition failed'

    gui.data = [ note_a, note_b ]

    gui.open_home_page

    gui.click today.strftime("%B %Y")

    refute gui.says?(note_a.content), 'Initial note incorrect'
    assert gui.says?(note_b.content), 'Initial note incorrect'

    gui.open_next_note

    assert gui.says?(note_a.content), 'next note incorrect'
    refute gui.says?(note_b.content), 'next note incorrect'
    refute gui.next_notes?, 'next link incorrect'
  end

  def test_does_not_display_useless_pagination
    note = FieldNotes::Entry.new today, 'Note A', 'foo'

    gui.data = [ note ]

    gui.open_home_page

    gui.click today.strftime("%B %Y")

    refute gui.pagination?, 'Pagination incorrect'
  end
end
