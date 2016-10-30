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

class Victoria
  def url
    'https://api.morph.io/auxesis/vic_health_register_of_convictions/data.json'
  end

  def morph_api_key
    ENV['MORPH_API_KEY']
  end

  def fetch
    params = { :key => morph_api_key, :query => "select * from 'data'" }
    result = RestClient.get(url, :params => params)
    @records = JSON.parse(result)
  end

  def geocoded
    @records.select { |r|
      !r['lat'].blank? && !r['lng'].blank?
    }
  end

  def md5(string)
    @hash ||= Digest::MD5.new
    @hash.hexdigest(string)
  end

  def businesses
    return @businesses if @businesses

    @businesses = geocoded.map do |r|
      {
        'id'      => md5(r['address']),
        'name'    => r['trading_name'],
        'lat'     => r['lat'].to_f,
        'lng'     => r['lng'].to_f,
        'address' => r['address'],
      }
    end

    @businesses.uniq! {|b| b['id'] }

    @businesses
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['address']),
        'date'        => Date.parse(r['conviction_date']),
        'link'        => r['link'],
        'description' => r['description'],
        'severity'    => 'major',
      }
    end
  end
end

class NSWProsecutions
  def url
    'https://api.morph.io/auxesis/nsw_food_authority_prosecution_notices/data.json'
  end

  def morph_api_key
    ENV['MORPH_API_KEY']
  end

  def fetch
    params = { :key => morph_api_key, :query => "select * from 'data'" }
    result = RestClient.get(url, :params => params)
    @records = JSON.parse(result)
  end

  def geocoded
    @records.select { |r|
      !r['lat'].blank? && !r['lng'].blank?
    }
  end

  def md5(string)
    @hash ||= Digest::MD5.new
    @hash.hexdigest(string)
  end

  def businesses
    return @businesses if @businesses

    @businesses = geocoded.map do |r|
      {
        'id'      => md5(r['offence_address']),
        'name'    => r['trading_name'],
        'lat'     => r['lat'].to_f,
        'lng'     => r['lng'].to_f,
        'address' => r['offence_address'],
      }
    end

    @businesses.uniq! {|b| b['id'] }

    @businesses
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['offence_address']),
        'date'        => Date.parse(r['offence_date']),
        'link'        => r['link'],
        'description' => r['description'],
        'severity'    => 'major',
      }
    end
  end
end

class NSWPenalties
  def url
    'https://api.morph.io/auxesis/nsw_food_authority_penalty_notices/data.json'
  end

  def morph_api_key
    ENV['MORPH_API_KEY']
  end

  def fetch
    params = { :key => morph_api_key, :query => "select * from 'data'" }
    result = RestClient.get(url, :params => params)
    @records = JSON.parse(result)
  end

  def geocoded
    @records.select { |r|
      !r['lat'].blank? && !r['lng'].blank?
    }
  end

  def md5(string)
    @hash ||= Digest::MD5.new
    @hash.hexdigest(string)
  end

  def businesses
    return @businesses if @businesses

    @businesses = geocoded.map do |r|
      {
        'id'      => md5(r['address']),
        'name'    => r['trading_name'],
        'lat'     => r['lat'].to_f,
        'lng'     => r['lng'].to_f,
        'address' => r['address'],
      }
    end

    @businesses.uniq! {|b| b['id'] }

    @businesses
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['address']),
        'date'        => Date.parse(r['offence_date']),
        'link'        => r['link'],
        'description' => r['offence_nature'],
        'severity'    => 'minor',
      }
    end
  end
end

class WA
  def url
    'https://api.morph.io/auxesis/wa_health_food_offenders/data.json'
  end

  def morph_api_key
    ENV['MORPH_API_KEY']
  end

  def fetch
    params = { :key => morph_api_key, :query => "select * from 'data'" }
    result = RestClient.get(url, :params => params)
    @records = JSON.parse(result)
  end

  def geocoded
    @records.select { |r|
      !r['lat'].blank? && !r['lng'].blank?
    }
  end

  def md5(string)
    @hash ||= Digest::MD5.new
    @hash.hexdigest(string)
  end

  def businesses
    return @businesses if @businesses

    @businesses = geocoded.map do |r|
      {
        'id'      => md5(r['business_location']),
        'name'    => r['business_name'],
        'lat'     => r['lat'].to_f,
        'lng'     => r['lng'].to_f,
        'address' => r['business_location'],
      }
    end

    @businesses.uniq! {|b| b['id'] }

    @businesses
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['business_location']),
        'date'        => Date.parse(r['date_of_conviction']),
        'link'        => r['notice_pdf_url'],
        'description' => r['offence_details'],
        'severity'    => 'major',
      }
    end
  end
end

class SA
  def url
    'https://api.morph.io/auxesis/sa_health_food_prosecutions_register/data.json'
  end

  def morph_api_key
    ENV['MORPH_API_KEY']
  end

  def fetch
    params = { :key => morph_api_key, :query => "select * from 'data'" }
    result = RestClient.get(url, :params => params)
    @records = JSON.parse(result)
  end

  def geocoded
    @records.select { |r|
      !r['lat'].blank? && !r['lng'].blank?
    }
  end

  def md5(string)
    @hash ||= Digest::MD5.new
    @hash.hexdigest(string)
  end

  def businesses
    return @businesses if @businesses

    @businesses = geocoded.map do |r|
      {
        'id'      => md5(r['address']),
        'name'    => r['trading_name'],
        'lat'     => r['lat'].to_f,
        'lng'     => r['lng'].to_f,
        'address' => r['address'],
      }
    end

    @businesses.uniq! {|b| b['id'] }

    @businesses
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['address']),
        'date'        => Date.parse(r['court_decision_date']),
        'link'        => r['link'],
        'description' => r['offence_nature'],
        'severity'    => 'major',
      }
    end
  end
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

sources = [ Victoria.new, NSWPenalties.new, NSWProsecutions.new, WA.new, SA.new ]
puts "Fetching #{sources.size} data sets."
sources.each {|s| s.fetch }

businesses = sources.map(&:businesses).flatten
puts "Total number of businesses: #{businesses.size}"
offences = sources.map(&:offences).flatten
puts "Total number of offences:   #{offences.size}"

new_businesses = businesses.select {|b| !existing_business_ids.include?(b['id']) }
new_offences   = offences.select   {|o| !existing_offence_ids.include?(o['link']) }

puts "### There are #{new_businesses.size} new businesses"
puts "### There are #{new_offences.size} new offences"

ScraperWiki.save_sqlite(['id'], new_businesses, 'businesses')
ScraperWiki.save_sqlite(['link'], new_offences, 'offences')
