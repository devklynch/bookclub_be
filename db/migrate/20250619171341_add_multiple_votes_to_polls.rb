class AddMultipleVotesToPolls < ActiveRecord::Migration[8.0]
  def change
    add_column :polls, :multiple_votes, :boolean
  end
end
