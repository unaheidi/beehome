module Service::Docker
  class DockerCreateContainerError < StandardError; end
  class DockerStartContainerError < StandardError; end

  class Request
    def initialize
      #@conn = Connection.new(remote_api_url: options[:remote_api_url])
      @conn = Connection.new( remote_api_url: "http://192.168.218.16:8090" )
    end

    def create_container(params = {})
      debugger
      params = {
        'Ip' => "192.168.218.254",
        'Image' => '93c447941695'
      }
      begin
        debugger
        @conn.post("/containers/create?name=alpha_" + params['Ip'], params.to_json).body
      rescue DockerCreateContainerError => ex
        raise DockerCreateContainerError.new(ex)
      end
    end

    def start_container(params = {})
      params = {
        "PublishAllPorts" => true,
      }.to_json
      begin
        debugger
        @conn.post("/containers/7dff1de7ab01/start", params).body
      rescue DockerStartContainerError => ex
        raise DockerStartContainerError.new(ex)
      end
    end

  end
end
