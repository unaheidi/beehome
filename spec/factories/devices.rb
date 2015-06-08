# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :device do
    status 2
    purpose "jagent,performance_test"
    processor_size  16
    memory_size     64
  end
end
