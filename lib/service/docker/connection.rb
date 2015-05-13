module Service::Docker
  class DockerConnectionError < StandardError; end

  class Connection
    include HTTParty

    def initialize(options = {})
      docker_remote_api = options[:docker_remote_api]
      self.class.base_uri(docker_remote_api)
      @timeout = options[:timeout] || 30
    end

    def post(path, options = {}, style = "form")
      begin
        Timeout::timeout(@timeout) do
          headers = {
            'Content-Type' => 'application/json'
          }
          params = (style == "form") ? {:body => options, headers: headers} : {:query => options, headers: headers}
          Rails.logger.info("connect: param:#{params}")
          self.class.post(path, params)
        end
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

    def delete(path, options = {})
      begin
        Timeout::timeout(@timeout) do
          self.class.delete(path, query: options)
        end
      rescue => ex
        raise DockerConnectionError.new(ex)
      end
    end

  end
end
