require 'timecop'
require 'active_support/core_ext/time/calculations'

Time.zone = "UTC" if Time.zone.nil?

Given /the timezone is "(.+?)"$/ do |zone|
  Time.zone = zone
end

Given /the (date|time|date and time) is (.+?)$/ do |datetime, value|
  time = case datetime
         when "date"
           Date.parse(value)
         when "time"
           Time.parse(value)
         when "date and time"
           Time.zone.parse(value)
         end
  Timecop.travel time
end

After do
  Timecop.return
end
