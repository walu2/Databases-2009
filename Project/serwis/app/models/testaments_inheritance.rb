class TestamentInheritance < ActiveRecord::Base
  set_table_name :osoba
  set_primary_key :id
  has_one :users_data, :foreign_key => "osoba_id"
end
