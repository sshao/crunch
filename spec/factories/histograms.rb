FactoryGirl.define do
  hist_hash = {"#EA3556" => 100,
               "#61D2D6" => 200,
               "#EDE5E2" => 300,
               "#ED146F" => 400,
               "#EDDE45" => 500,
               "#9BF0E9" => 600}

  factory :histogram do 
    username      "arrow"
    histogram     hist_hash
    source_ts     1404670749
    dataset_size  5
  end

  factory :invalid_histogram, parent: :histogram do
    username    nil
  end
end

