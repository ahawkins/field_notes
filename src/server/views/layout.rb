module Views
  class Layout < Mustache

    def year
      Date.today.year
    end
  end
end
