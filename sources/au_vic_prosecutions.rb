module Australia
  class Victoria
    include Source

    description 'Victoria Health register of food safety convictions'

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
end
