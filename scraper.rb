#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'scraped_page_archive'
require 'require_all'
require_rel 'lib'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

url = 'http://www.hcdn.gob.ar/diputados/listadip.html'
MembersPage.new(response: Scraped::Request.new(url: url).response).members.each do |member|
  data = [
    member.section,
    member.page
  ].map(&:to_h).reduce(&:merge)
  ScraperWiki.save_sqlite([:id, :term], data)
end
