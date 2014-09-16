# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    repository "docker.diors.it/alpha_machine"
    dockerfile_url nil

    factory :alpha_v1_0 do
      tag "v1.0"
      image_id "93c447941695"
      purpose "alpha"
      status 0
    end

    factory :alpha_v1_1 do
      tag "v1.1"
      image_id "77c447941689"
      purpose "alpha"
      status 1
    end

    factory :alpha_v1_2 do
      tag "v1.2"
      image_id "45002345679c"
      purpose "alpha"
      status 2
    end

  end
end
