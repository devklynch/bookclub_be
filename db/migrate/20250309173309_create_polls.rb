class CreatePolls < ActiveRecord::Migration[8.0]
  def change
    create_table :polls do |t|
      t.string :poll_question
      t.datetime :expiration_date
      t.references :book_club, null: false, foreign_key: true
      t.timestamps
    end
  end
end
