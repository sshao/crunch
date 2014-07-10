FactoryGirl.define do
  factory :histogram do 
    username      "arrow"
    source_ts     1404670749
    dataset_size  5
  end

  factory :invalid_histogram, parent: :histogram do
    username    "idontexist"
  end
end

