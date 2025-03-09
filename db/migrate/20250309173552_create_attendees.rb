class CreateAttendees < ActiveRecord::Migration[8.0]
  def change
    create_table :attendees do |t|
      t.boolean :attending
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.timestamps
    end
  end
end
