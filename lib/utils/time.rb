module Utils
  module Time
    def ts
      @ts ||= ::Time.now.strftime("%Y%m%d%H%M%S")
    end
  end
end
