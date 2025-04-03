# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      ## Devise requires `encrypted_password` instead of `password`
      t.rename :password, :encrypted_password # Rename existing `password` column

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Add unique index for Devise email (optional, since email is already present)
      t.index :email, unique: true
      t.index :reset_password_token, unique: true
    end
  end
end
