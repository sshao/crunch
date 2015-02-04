describe Crunch do
  describe ".crunch" do
    it "crunches an array of hashes together" do
      data1 = { "#FFFFFF" => 10 }
      data2 = { "#FFFFFE" => 20 }
      data3 = { "#FFFFFD" => 5 }
      data_array = [data1, data2, data3]
      expected = { "#FFFFFE" => 35 }

      expect(Crunch.crunch(data_array)).to eq expected
    end

    it "combines two similar colors together" do
      data = { "#FFFFFF" => 10, "#FFFFFE" => 20 }
      expected = { "#FFFFFE" => 30 }

      expect(Crunch.crunch(data)).to eq expected
    end

    it "combines many similar colors together" do
      data = { "#FFFFFF" => 10, "#fa2b18" => 4, "#FFFFFE" => 20, "#f82126" => 8,
               "#f31c21" => 10, "#bbb4b8" => 1, "#c3bbc0" => 2, "#f22328" => 5}
      expected = { "#FFFFFE" => 30, "#f31c21" => 27, "#c3bbc0" => 3 }

      expect(Crunch.crunch(data)).to eq expected
    end
  end
end
