#!/usr/bin/env ruby

require 'harvested'
require 'date'

credentials = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config", "credentials.yml"))
@harvest = Harvest.hardy_client(credentials['subdomain'], credentials['user'], credentials['password'])

@current_year = Date.today.year
@beginning_of_year = Date.parse("#{@current_year}-01-01")
@end_of_year = Date.parse("#{@current_year}-12-31")

projects = @harvest.projects.all
personal_slack_project = projects.detect { |p| p.name == "Personal Slack" }
corporate_slack_project = projects.detect { |p| p.name == "Corporate Slack" }

def hours_for(user, options = {})
  entries = @harvest.reports.time_by_user(user, @beginning_of_year, @end_of_year, options)
  entries.map(&:hours).inject(0) {|sum,h| sum + h.to_f }
end

def corporate_slack_earned(billable_hours)
  billable_hours * 0.15
end

def personal_slack_earned(billable_hours)
  billable_hours * 0.1
end

def f(float)
  "%.2f" % float
end

puts <<-REPORT
#{@current_year} Slack Report
-----------------------------------------------------------------------------------

REPORT

@harvest.users.all.each do |user|
  hours_billed = hours_for(user, billable: true)
  personal_slack_used = hours_for(user, project: personal_slack_project)
  corporate_slack_used =  hours_for(user, project: corporate_slack_project)

  puts <<-REPORT
    #{user.first_name} #{user.last_name} (#{user.email})
    -------------------------------------------------------------------------------
    Total Hours Billed       : #{hours_billed}

    Corporate Slack earned   : #{f corporate_slack_earned(hours_billed)}
    Corporate Slack used     : #{corporate_slack_used}
    Corporate Slack available: #{f corporate_slack_earned(hours_billed) - corporate_slack_used}

    Personal Slack earned    : #{f personal_slack_earned(hours_billed)}
    Personal Slack used      : #{personal_slack_used}
    Personal Slack available : #{f personal_slack_earned(hours_billed) - personal_slack_used}

  REPORT
end



0