class Testaments < ActiveRecord::Base
  set_table_name :osoba
  set_primary_key :id
  has_one :users_data, :foreign_key => "osoba_id"


 def self.generateBlock(amount = 15) 
  h = Hash.new
  for i in 1..amount do
   key = i.to_s + ' osob'
   h[key.to_sym] = i
  end
   return h.sort_by { |k,v| v }
 end


end
