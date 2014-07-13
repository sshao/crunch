class RemoveDatasetSizeFromHistograms < ActiveRecord::Migration
  def change
    remove_column :histograms, :dataset_size, :integer
  end
end
