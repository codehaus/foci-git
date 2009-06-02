require_dependency 'helpers/render_helper'

class CoreController < ApplicationController
  before_filter :filter_vhost

  def index
    @period = nil
    
    if params.has_key?(:period)
      @period = Period.find_by_id(params[:period])
      if not @period
        render '/core/no_such_period'
        return
      end
    end

    if not @vhost and not @period
      render :file => RAILS_ROOT + '/app/views/search/index.rhtml'
      return
    end
    
    @totals = PathTotal.totals_for_vhost_period( @vhost, @period  )
    
    @recent_periods = Period.find_recent(@vhost)
  end
  
  private

  def filter_vhost
    @vhost = params[:vhost]
  end
end
