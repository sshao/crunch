class AddOffsetToHistogram < ActiveRecord::Migration
  def change
    add_column :histograms, :offset, :integer
  end
end
