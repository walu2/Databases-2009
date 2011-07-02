class Eventfiles < ActiveRecord::Base
  set_table_name :dokumenty
  set_primary_key :id
  belongs_to :events, :foreign_key => "id"

def self.save(upload)
name = upload['datafile'].original_filename
directory = "public/files"
# create the file path
path = File.join(directory, name)
# write the file
File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
end

 def self.sanitize_filename(file_name)
  # get only the filename, not the whole path (from IE)
  just_filename = File.basename(file_name) 
  # replace all none alphanumeric, underscore or perioids
  # with underscore
  just_filename.sub(/[^\w\.\-]/,'_') 
 end

 def self.getAllData
  find :all, :order => 2
 end

end
