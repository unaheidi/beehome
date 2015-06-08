# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :container do
    association :image
    association :ip_address
    status 1

    factory :container_private do
      processor_occupy_mode  "private"
    end

    factory :container_share do
      processor_occupy_mode  "share"
    end

  end
end
