class SearchController < ApplicationController

  def index
    search_type = params[:search_type]
    #search_parameter = params[:search_parameter]
    puts "search_type => #{search_type}"

    if search_type == "domain"
      @search_domain = params[:search_domain]
      puts "search_domain for domain '#{@search_domain}'"
      @vhosts = Vhost.find(:all, :conditions => [ 'host LIKE ?',
                                                  "%#{@search_domain}%"] )
      render :action => 'search_domains'

      return
    end
    
    render :action => 'index'
  end
end
