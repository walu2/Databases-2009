class UsersData < ActiveRecord::Base
  set_table_name :dane_osobowe
  set_primary_key :osoba_id
  belongs_to :users, :foreign_key => "osoba_id"

  protected
   def validate
     regDate = Regexp.new('(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)[0-9]{2}')
     errors.add_on_empty %w( miejsce_urodzenia),"nie powinno pozostac puste"
   end

end
