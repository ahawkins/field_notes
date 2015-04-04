module Views
  class Index < Mustache
    DateLink = Struct.new :date do
      def link
        "/#{date.strftime("%Y/%m")}"
      end

      def text
        date.strftime "%B %Y"
      end
    end

    def dates
      @entries.uniq { |e| [ e.date.year, e.date.month ] }.map { |e| DateLink.new e.date }
    end
  end
end
