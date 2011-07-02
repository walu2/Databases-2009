class EventfilesController < ApplicationController

  def new
    @docs = Eventfiles.new
  end

  def addNew
    @currentEvents = Events.showAllEvents

    if request.post? & flash[:send].nil? then
     
     @docs = Eventfiles.new(params[:doc])


     if @docs.valid? then 
       Eventfiles.save(params[:upload])
          
       flash[:send] = "Informacje dodane"
       @docs.sciezka_do_zdjecia = params[:upload].nil? ? "" : params[:upload]['datafile'].original_filename;
       @docs.save!; 
     end

     #redirect_to :action => 'show'; return nil
    end
  end

  def allEventFiles
    @allFiles_ = Eventfiles.find(:all)
  end

end
