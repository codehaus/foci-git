# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include RenderHelper

  attr_reader :page_title
  
  def set_page_title(page_title)
    @page_title = h(page_title)
  end
  
  def render_top_reports(top_report_type, count = 0)
    html = ""
    #top_report_type = TopReportType.find_by_key(top_report_type_key)
    html << "<table class='grid top-reports #{top_report_type.key}'>"
    html << "<thead><tr><th>Title</th><th>Description</th></tr></thead>"
    reports = TopReport.find(:all, :conditions => [ 'top_report_type_id = ?', top_report_type.id], :order => 'sort', :limit => (count == 0 ? nil : count))
    for report in reports
      html << "<tr class='top-report'><td class='title'><a href='#{report.url}' title='#{report.title}'>#{report.title}</a></td><td class='description'>#{ report.description }</td></tr>"
    end
    html << "</table>"
  end

end
