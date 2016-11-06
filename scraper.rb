# Get data from the morph.io api
require 'rest-client'
require 'json'
require 'pry'
require 'scraperwiki'
require 'active_support'
require 'active_support/core_ext'
require 'date'

if ENV['MORPH_API_KEY'].blank?
  puts "Must have MORPH_API_KEY set"
  exit(1)
end

def existing_business_ids
  return @cached_businesses if @cached_businesses
  @cached_businesses = ScraperWiki.select('id from businesses').map {|r| r['id']}
rescue SqliteMagic::NoSuchTable
  []
end

def existing_offence_ids
  return @cached_offences if @cached_offences
  @cached_offences = ScraperWiki.select('link from offences').map {|r| r['link']}
rescue SqliteMagic::NoSuchTable
  []
end

SOURCES = []

module Source
  def self.included(base)
    base.instance_eval do
      def description(*args)
        if args.size > 0
          @description = args.join(' ')
        else
          @description
        end
      end
    end
    base.class_eval do
      def description
        self.class.description || self.class.to_s.split('::',2)[1]
      end
    end
    SOURCES << base.new
  end
end

def sources
  @sources ||= SOURCES.dup
end

def pretty_print_data_sources(sources)
  puts "### Detected #{sources.size} sources"
  puts
  jurisdictions = {}
  sources.each do |source|
    jurisdiction = source.class.to_s.split('::').first
    jurisdictions[jurisdiction] ||= []
    jurisdictions[jurisdiction] << source.description
  end

  jurisdictions.sort.each do |jurisdiction, descriptions|
    puts "#{jurisdiction}:"
    puts
    descriptions.sort.each do |description|
      puts " - #{description}"
    end
    puts
  end
end

root = Pathname.new(__FILE__).parent
$: << root.to_s
glob = root + 'sources' + '*.rb'
files = Pathname.glob(glob)
files.each { |f| require(f.to_s) }

pretty_print_data_sources(sources)

puts "### Fetching data from #{sources.size} sources"
sources.each {|s| s.fetch }

businesses = sources.map(&:businesses).flatten
puts "### Total number of businesses: #{businesses.size}"
offences = sources.map(&:offences).flatten
puts "### Total number of offences:   #{offences.size}"

new_businesses = businesses.select {|b| !existing_business_ids.include?(b['id']) }
new_offences   = offences.select   {|o| !existing_offence_ids.include?(o['link']) }

puts "### There are #{new_businesses.size} new businesses"
puts "### There are #{new_offences.size} new offences"

ScraperWiki.save_sqlite(['id'], new_businesses, 'businesses')
ScraperWiki.save_sqlite(['link'], new_offences, 'offences')
