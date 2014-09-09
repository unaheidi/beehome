module API

  class Containers < Grape::API

    namespace 'containers' do

      get "/" do
        { containers: 1 }
      end

    end 
  end
end

