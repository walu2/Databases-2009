class Events < ActiveRecord::Base
  set_table_name :wydarzenie
  set_primary_key :id
  has_many :eventfiles, :foreign_key => "id_wydarzenia"

 def self.showAllEvents
   find :all
 end


 def self.typeHelper(param)
     case param
      when 0
       "Pogrzeb"
      when 1
       "Slub"
      when 2
       "Rozwod"
      else
       "blad!"
     end
 end

 def self.UserToHashMapHelper(param)
      h = Hash.new 
      param.each  do |c|
       key = c.imie + ' ' + c.nazwisko
       h[key.to_sym] = c.id
     end
    return h
   end

  def self.EventsToHashMapHelper(param) 
      h = Hash.new
      param.each  do |c|

        c.typ = -1 if c.typ.nil?
        c.miejsce = "" if c.miejsce.nil?
        c.data = DateTime.now if c.data.nil?

       key = self.typeHelper(c.typ.to_i) + ' w: ' + c.miejsce + '[' + c.data.strftime("%m/%d/%Y") + ']'
       h[key.to_sym] = c.id
     end
    return h
  end

  protected
   def validate
     errors.add_on_empty %w( miejsce )

   end

end
