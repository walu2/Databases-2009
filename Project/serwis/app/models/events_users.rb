require 'rubygems'
require 'composite_primary_keys'

class EventsUsers < ActiveRecord::Base

  set_table_name :osoba_wydarzenie
  set_primary_keys :id_osoby #, :id_wydarzenia 

 def self.showAllEvents
   find :all
 end

end
