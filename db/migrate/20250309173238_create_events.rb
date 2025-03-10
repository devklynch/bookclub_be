class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :event_name
      t.datetime :event_date
      t.string :location
      t.string :book
      t.string :event_notes
      t.references :book_club, null: false, foreign_key: true
      t.timestamps
    end
  end
end
