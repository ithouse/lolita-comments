class CreateLolitaComments < ActiveRecord::Migration
  def self.up
    create_table :comments,:force=>true do |t|
      t.string  :commentable_type
      t.integer  :commentable_id
      t.integer :commentator_type
      t.integer :commentator_id
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string  :commentator_name
      t.string  :email
      t.text    :body
      t.integer :reply_count
      t.timestamps
    end

    add_index :comments, [:commentable_type,:commentable_id],:name=>"commentable"
    add_index :comments, [:commentator_type,:commentator_id],:name=>"commentator"
    add_index :comments, :reply_count
    add_index :comments, :created_at
    add_index :comments, :updated_at
    add_index :comments, [:parent_id,:lft,:rgt]
  end

  def self.down
    drop_table :comments
  end
end
