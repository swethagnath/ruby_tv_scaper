#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "time"
require "httparty"

# Represents a single TV program
class TvProgram
  attr_reader :channel_name, :start_time, :title, :end_time

  def initialize(channel_name:, start_time:, title:, end_time: nil)
    @channel_name = channel_name
    @start_time   = start_time
    @title        = title
    @end_time     = end_time
  end

  def to_h
    {
      channel_name: channel_name,
      start_time:   start_time,
      title:        title,
      end_time:     end_time
    }
  end

  def to_s
    "[#{channel_name}] #{start_time} - #{end_time || '??:??'} : #{title}"
  end
end

# Scraper that talks directly to DR's schedule API (kept very simple)
class DrTvGuideScraper
  BASE_API_URL = "https://prod95-cdn.dr-massive.com/api/schedules"
  CHANNEL_IDS  = "20875,20876,20892,22463,192099"

  def initialize(date: Date.today)
    @date = date
  end

  # Single method that:
  # - builds the URL
  # - calls the API
  # - parses JSON
  # - returns an array of TvProgram
  def fetch_schedule
    date_str = @date.strftime("%Y-%m-%d")

    url = "#{BASE_API_URL}?" \
          "channels=#{CHANNEL_IDS}" \
          "&date=#{date_str}" \
          "&device=web_browser" \
          "&duration=24" \
          "&ff=idp%2Cldp%2Crpt" \
          "&geoLocation=abroad" \
          "&hour=23" \
          "&isDeviceAbroad=true" \
          "&lang=da" \
          "&segments=drtv%2Coptedin" \
          "&sub=Anonymous2"

    response = HTTParty.get(url)
    raise "Failed to fetch TV schedule API (status: #{response.code})" unless response.success?

    data = JSON.parse(response.body)
    parse_time = ->(iso) do
      next nil if iso.nil? || iso.empty?
      Time.parse(iso).getlocal.strftime("%H:%M")
    rescue ArgumentError
      nil
    end

    programs = []

    Array(data).each do |group|
      (group["schedules"] || []).each do |schedule|
        item = schedule["item"] || {}

        channel_name =
          item["broadcastChannel"] ||
          item.dig("customFields", "BroadcastChannel") ||
          "Unknown"

        start_time_iso =
          schedule["startTimeInDefaultTimeZone"] ||
          item["broadcastChannelStart"]

        end_time_iso =
          schedule["endTimeInDefaultTimeZone"] ||
          schedule["endDate"]

        title = item["title"] || "Untitled"

        programs << TvProgram.new(
          channel_name: channel_name,
          start_time:   parse_time.call(start_time_iso),
          title:        title,
          end_time:     parse_time.call(end_time_iso)
        )
      end
    end

    programs
  end
end

if __FILE__ == $PROGRAM_NAME
  # Read date from first argument or use today
  date =
    begin
      ARGV[0] ? Date.parse(ARGV[0]) : Date.today
    rescue ArgumentError
      warn "Invalid date format, using today instead."
      Date.today
    end

  puts "Fetching DR TV guide for #{date}..."

  scraper  = DrTvGuideScraper.new(date: date)
  programs = scraper.fetch_schedule

  if programs.empty?
    puts "No programs found in API response."
    exit 0
  end

  puts
  puts "=== TV Schedule for #{date} ==="
  programs.each { |p| puts p }

  output_file = "tv_schedule_#{date}.json"
  File.open(output_file, "w:utf-8") do |f|
    f.write(JSON.pretty_generate(programs.map(&:to_h)))
  end

  puts
  puts "Saved JSON schedule to #{output_file}"
end



