class Users < ActiveRecord::Base
  set_table_name :osoba
  set_primary_key :id
  has_one :users_data, :foreign_key => "osoba_id"

  def users_data=(params) 
    build_users_data(params) # !!
  end
  
   def self.getAllDataFromUsers
     find :all, :order => "nazwisko ASC" 
   end

   def self.getAllAlive
     find_by_sql "SELECT * 
                  FROM osoba o, dane_osobowe ds
                  WHERE o.id = ds.osoba_id AND ds.powod_zgonu IS NULL"
   end 

   def self.getAllDead
     find_by_sql "SELECT * 
                  FROM osoba o, dane_osobowe ds
                  WHERE o.id = ds.osoba_id AND ds.powod_zgonu IS NOT NULL"
   end

   def self.getMotherToId(paramId)
     find(:first, :conditions => ["id = ?", paramId], :select => :id_matki)
   end

   def self.getFatherToId(paramId)
     find(:first, :conditions => ["id = ?", paramId], :select => :id_ojca)
   end

   def self.getParentsToId(paramId)
     result = Hash.new( {:f, :m})
     result[:f] = getFatherToId(paramId)
     result[:m] = getMotherToId(paramId)
     return result
   end   
  
  def self.getInfoAboutPerson(paramId)
    find :all, :conditions => ["id = ?", paramId], :include => :users_data
  end


  protected
   def validate
     errors.add_on_empty %w( imie nazwisko )
   end

end
