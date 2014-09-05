module Service::Docker
  class DockerConnectionError < StandardError; end

  class Connection
    include HTTParty

    def initialize(options = {})
      remote_api_url = options[:remote_api_url]
      self.class.base_uri(remote_api_url)
      @timeout = options[:timeout] || 30
    end

    def post(path, options = {}, style = "form")
      begin
        #Timeout::timeout(@timeout) do
          headers = {
            'Content-Type' => 'application/json'
          }
          params = (style == "form") ? { :body => options, headers: headers} : { :query => options }
          self.class.post(path, params)
        #end
      rescue => ex
        raise DockerConnectionError.new(ex)
      end
    end

    def get(path, options = {})
      begin
        Timeout::timeout(@timeout) do
          self.class.get(path, query: options)
        end
      rescue => ex
        raise DockerConnectionError.new(ex)
      end
    end

  end
end
