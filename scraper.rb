#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def date_from(str)
  return if str.to_s.empty?
  Date.parse str
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('#tablaDiputados a[href*="/diputados/"]').each do |a|
    puts a.text.split(', ').reverse.join(' ').tidy
    person_url = URI.join url, a.attr('href')
    data = {
      id:            a.attr('href').split('/').last,
      name:          a.text.split(', ').reverse.join(' ').tidy,
      sort_name:     a.text.tidy,
      district:      a.xpath('following::td')[0].text.tidy,
      mandate_start: date_from(a.xpath('following::td')[1].text.tidy).to_s,
      mandate_end:   date_from(a.xpath('following::td')[2].text.tidy).to_s,
      party:         a.xpath('following::td')[3].text.tidy,
      term:          133,
      source:        person_url.to_s,
    }.merge(scrape_person(person_url))
    data[:start_date] = data[:mandate_start] if data[:mandate_start] > '2015-01-01'
    data[:end_date] = data[:mandate_end] if data[:mandate_end] < '2015-12-31'
    puts data.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h if ENV['MORPH_DEBUG']
    ScraperWiki.save_sqlite(%i[id term], data)
  end
end

def scrape_person(url)
  noko = noko_for(url)
  data = {
    image: noko.css('div.foto-diputados-principal img/@src').text,
    phone: noko.css('div.info-diputados-principal1').text[/Teléfono: (.*)$/, 1].to_s.tidy,
    email: noko.css('div.info-diputados-principal2 a[href*="/contacto"]').text.tidy,
  }
  data
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_list('https://www.hcdn.gob.ar/diputados/listadip.html')
