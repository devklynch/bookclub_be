class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :book_club, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :status, default: 'pending'
      t.string :token, null: false
      t.datetime :accepted_at
      t.datetime :declined_at
      
      t.timestamps
    end
    
    add_index :invitations, :email
    add_index :invitations, :token, unique: true
    add_index :invitations, [:book_club_id, :email], unique: true
    add_index :invitations, :status
  end
end
