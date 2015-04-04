module Views
  class Month < Mustache
    Link = Struct.new :date do
      def path
        "/#{date.strftime("%Y-%m")}"
      end
    end

    Pagination = Struct.new :previous_link, :next_link

    Section = Struct.new :name, :entries

    Note = Struct.new :entry, :markdown do
      def date
        entry.date.strftime "%Y-%m-%d"
      end

      def html
        markdown.html entry.content
      end
    end

    # NOTE: override the render method to calculate shared variables
    # instead of having to memoize.
    def render(data = template, ctx = { })
      @notes = @entries.
        select { |e| e.year == @date.year && e.month == @date.month }.
        sort { |e1, e2| e2.date <=> e1.date }

      @older_notes = @entries.
        sort { |e1, e2| e2.date <=> e1.date }.
        select do |e|
          if e.year == @date.year
            e.month < @date.month
          else
            e.year < @date.year
          end
        end

      @newer_notes = @entries.
        sort { |e1, e2| e2.date <=> e1.date }.
        select do |e|
          if e.year == @date.year
            e.month > @date.month
          else
            e.year > @date.year
          end
        end

      if @older_notes.any? || @newer_notes.any?
        @pagination = Pagination.new.tap do |pagination|
          pagination.previous_link = Link.new(@older_notes.last.date) if @older_notes.any?
          pagination.next_link = Link.new(@newer_notes.first.date) if @newer_notes.any?
        end
      end

      super
    end

    def pagination
      @pagination
    end

    def sections
      @notes.group_by(&:tag).map do |tag, entries|
        Section.new(tag).tap do |section|
          section.entries = entries.map { |e| Note.new(e, @markdown_generator) }
        end
      end
    end

    def date
      @date.strftime "%B %Y"
    end
  end
end
