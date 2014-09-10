module API

  class Images < Grape::API

    namespace 'images' do

      get "/" do
        { images: 1 }
      end

    end 
  end
end

