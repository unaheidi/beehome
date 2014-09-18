module Service::Gitpub
  class GitpubConnectionError < StandardError; end

  class Connection
    include HTTParty

    def initialize(options = {gitpub_url: "http://192.168.9.87:3000/"})
      self.class.base_uri(options[:gitpub_url])
      @timeout = options[:timeout] || 30
    end

    def post(path, options = {}, style = "form")
      begin
        Timeout::timeout(@timeout) do
          headers = {
            'Content-Type' => 'application/json'
          }
          params = (style == "form") ? {:body => options, headers: headers} : {:query => options, headers: headers}
          self.class.post(path, params)
        end
      rescue => ex
        raise GitpubConnectionError.new(ex)
      end
    end

    def get(path, options = {})
      begin
        Timeout::timeout(@timeout) do
          self.class.get(path, query: options)
        end
      rescue => ex
        raise GitpubConnectionError.new(ex)
      end
    end

  end
end
