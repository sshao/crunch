class ChangeDefaultForHistogramOffsets < ActiveRecord::Migration
  def change
    change_column :histograms, :offset, :integer, :default => 0
  end
end
