FactoryGirl.define do
  factory :histogram do 
    username      "arrow"
    # FIXME source_ts should also be computed... as should dataset_size
    source_ts     1404670749
  end

  factory :invalid_histogram, parent: :histogram do
    username    "idontexist"
  end
end

