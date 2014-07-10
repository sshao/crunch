class CreateHistograms < ActiveRecord::Migration
  def change
    create_table :histograms do |t|
      t.string :username
      t.text :histogram
      t.timestamp :source_ts
      t.integer :dataset_size

      t.timestamps
    end
    add_index :histograms, :username, unique: true
  end
end
