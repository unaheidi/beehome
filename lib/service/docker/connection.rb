module Service::Docker
  class DockerConnectionError < StandardError; end

  class Connection
    include HTTParty

    def initialize(options = {})
      remote_api_url = options[:remote_api_url]
      self.class.base_uri(remote_api_url)
      @timeout = options[:timeout] || 30
    end

    def post(path, params = {}, param_style = "form")
      begin
        response = Timeout::timeout(@timeout) do
          headers = {
            'Content-Type' => 'application/json'
          }
          options = (param_style == "form") ? { :body => params, headers: headers } : { :query => params }
          self.class.post(path, options)
        end
      rescue => ex
        raise DockerConnectionError.new(ex)
      end
      response
    end

    def get(path, params = {})
      begin
        Timeout::timeout(@timeout) do
          self.class.get(path, query: params)
        end
      rescue => ex
        raise DockerConnectionError.new(ex)
      end
    end

  end
end
