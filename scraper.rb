# Get data from the morph.io api
require 'rest-client'
require 'json'
require 'pry'
require 'scraperwiki'
require 'active_support'
require 'active_support/core_ext'
require 'date'

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
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['address']),
        'date'        => Date.parse(r['conviction_date']),
        'link'        => r['link'],
        'description' => r['description'],
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
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['offence_address']),
        'date'        => Date.parse(r['offence_date']),
        'link'        => r['link'],
        'description' => r['description'],
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
  end

  def offences
    return @offences if @offences

    @offences = geocoded.map do |r|
      {
        'business_id' => md5(r['address']),
        'date'        => Date.parse(r['offence_date']),
        'link'        => r['link'],
        'description' => r['offence_nature'],
      }
    end
  end
end

sources = [ Victoria.new, NSWPenalties.new, NSWProsecutions.new ]
puts "Fetching #{sources.size} data sets"
sources.each {|s| s.fetch }

businesses = sources.map {|s| s.businesses }.flatten
puts "Number of businesses: #{businesses.size}"
offences   = sources.map {|s| s.offences   }.flatten
puts "Number of offences:   #{offences.size}"

ScraperWiki.save_sqlite(['id'], businesses, 'businesses')
ScraperWiki.save_sqlite(['link'], offences, 'offences')
