class TestamentsController < ApplicationController

 def new
  
 end

 def manage
  @possibleUsers = Users.find(:all, :conditions => ["testament = ?", TRUE])
 end
 
 def managebyid
   unless request.post? then 
    redirect_to :action => 'errorPage'; return nil;
   else
    @nrOfForms = params[:howMany]
    @initMoney = params[:money].to_i
    @uId = params[:userId]
   end
 end

 def errorPage
 end

end
