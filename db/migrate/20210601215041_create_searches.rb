class CreateSearches < ActiveRecord::Migration[6.1]
  def change
    create_table :searches do |t|
      t.string :ticker
      t.string :type
      t.datetime :timestamp

      t.timestamps
    end
  end
end