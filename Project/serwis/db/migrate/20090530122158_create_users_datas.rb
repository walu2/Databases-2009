class CreateUsersDatas < ActiveRecord::Migration
  def self.up
    create_table :users_datas do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :users_datas
  end
end
