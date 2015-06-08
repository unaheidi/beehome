# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    repository "docker.diors.it/alpha_machine"
    dockerfile_url nil

    factory :alpha_v1_0 do
      tag "v1.0"
      image_id "93c447941696"
      purpose "alpha"
    end

    factory :alpha_v1_1 do
      tag "v1.1"
      image_id "77c447941689"
      purpose "alpha"
    end

    factory :alpha_v1_2 do
      tag "v1.2"
      image_id "45002345679c"
      purpose "alpha"
    end

    factory :performance_v1_3 do
      tag "v1.3"
      image_id "6700234ytref"
      purpose "performance_test"
    end

  end
end
