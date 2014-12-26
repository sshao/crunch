FactoryGirl.define do
  factory :histogram do
    username      "arrow"
  end

  factory :invalid_histogram, parent: :histogram do
    username    "idontexist"
  end
end

