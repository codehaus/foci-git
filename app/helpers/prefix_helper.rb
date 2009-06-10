module PrefixHelper
  def periodically_check_progress options={}
    frequency = options[:frequency] || 10
    url = url_for(options[:url])
    element = options[:element]
    error = options[:error]
    js = "new PeriodicalExecuter(progressUpdater.curry('#{url}', '#{element}',
                                                '#{error}'), #{frequency})"

    javascript_tag js
  end
end

