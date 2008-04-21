# A plain old application controller that has been MOled...
class MoledController < ApplicationController  
  def index
  end
  
  # A plain ol' feature
  def my_action
    session[:user] = "Fernand"
    @state         = "Fred"    
    render :template => "moled/result"
  end
  
  # A slow action
  def my_slow_action
    sleep( 2 )
    render :template => "moled/result"
  end
  
  # Hosed action
  def my_hosed_action
    raise "This will hose your app"
  end
end