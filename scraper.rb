#!/bin/env ruby
# encoding: utf-8

require 'date'
require 'combine_popolo_memberships'
require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def date_from(str)
  return if str.to_s.empty?
  Date.parse str
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
  # Nokogiri::HTML(open(url).read, nil, 'utf-8')
end

# The terms of deputies are 4 years long, but offset by two years from
# half of their colleagues, so we're assuming that each year is a
# different term. Each session runs from the 1st of March to the 30th
# of November each year, [1] so treat those as the start and end dates
# of each "term". 2015 is the 133rd session of the Chamber of
# Deputies, 2016 is the 134th session, etc.
# [1] https://en.wikipedia.org/wiki/National_Congress_of_Argentina
terms = (2015..Date.today.year).map do |year|
  {
    # The session ID goes up 1 per year and 133 = 2015 - 1882
    id: year - 1882,
    start_date: Date.new(year, 3, 1).to_s,
    end_date: Date.new(year, 11, 30).to_s,
  }
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('#tablaPpal table td a[href*="/diputados/"]').map do |a|
    person_url = URI.join url, a.attr('href')
    data = { 
      id: a.attr('href').split("/").last,
      name: a.text.split(', ').reverse.join(" ").tidy,
      sort_name: a.text.tidy,
      district: a.xpath('following::td')[0].text.tidy,
      mandate_start: date_from(a.xpath('following::td')[1].text.tidy).to_s,
      mandate_end: date_from(a.xpath('following::td')[2].text.tidy).to_s,
      start_date: date_from(a.xpath('following::td')[1].text.tidy).to_s,
      end_date: date_from(a.xpath('following::td')[2].text.tidy).to_s,
      party: a.xpath('following::td')[3].text.tidy,
      source: person_url.to_s,
    }.merge(scrape_person(person_url))
    data
  end
end

def scrape_person(url)
  noko = noko_for(url)
  data = { 
    image: noko.css('div.foto-diputados-principal img/@src').text,
    phone: noko.css('div.info-diputados-principal1').text[/Teléfono: (.*)$/, 1].to_s.tidy,
    email: noko.css('div.info-diputados-principal2 a[href*="/contacto"]').text.tidy,
  }
  return data
end

membership_from_page = scrape_list('http://www.hcdn.gob.ar/diputados/listadip.html')

data = CombinePopoloMemberships.combine(
  id: membership_from_page,
  term: terms,
)

ScraperWiki.save_sqlite([:id, :term], data)
