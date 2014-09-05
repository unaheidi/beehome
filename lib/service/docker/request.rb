module Service::Docker
  class DockerCreateImageError < StandardError; end
  class DockerCreateContainerError < StandardError; end
  class DockerStartContainerError < StandardError; end

  class Request
    attr_reader :conn
    def initialize(options = {remote_api_url: "http://"})
      remote_api_url = options[:remote_api_url] || options['remote_api_url']
      @conn = Connection.new(remote_api_url: remote_api_url) # remote_api_url: "http://192.168.218.15:8090"
    end

    def create_image(options = {fromImage: 'docker.diors.it/alpha_machine', tag: 'v1.0'})
      begin
        @conn.post("/images/create", options, "query").code
      rescue DockerCreateImageError => ex
        raise DockerCreateImageError.new(ex)
      end
    end

    def create_container(options = {})
      debugger
      params = {
        'Ip' => options[:ip] || options['ip'] , # '192.168.218.253/24@192.168.218.1'
        'Image' => options[:image] || options['image'],  # 'docker.diors.it/alpha_machine:v1.0'
      }
      begin
        @conn.post("/containers/create?name=alpha_" + params['Ip'].sub(/\/.*/,''), params.to_json, "form")
      rescue DockerCreateContainerError => ex
        raise DockerCreateContainerError.new(ex)
      end
    end

    def start_container(options = {})
      debugger
      params = {
        "PublishAllPorts" => true,
      }
      container = options[:container] || options['container']
      begin
        @conn.post("/containers/#{container}/start", params.to_json, "form").body
      rescue DockerStartContainerError => ex
        raise DockerStartContainerError.new(ex)
      end
    end

  end
end
