module UK
  class FSA
    include Source

    description 'Food Standard Agency food law prosecutions outcomes database'

    def url
      'https://api.morph.io/auxesis/uk_fsa_food_law_prosecutions/data.json'
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

    def id(attrs)
      [ attrs['address'], attrs['county'], attrs['postcode'] ].join(', ')
    end

    def businesses
      return @businesses if @businesses

      @businesses = geocoded.map do |r|
        {
          'id'      => md5(id(r)),
          'name'    => r['trading_name'] || r['food_business_operator'] || r['defendant'],
          'lat'     => r['lat'].to_f,
          'lng'     => r['lng'].to_f,
          'address' => [ r['address'], r['county'], r['postcode'] ].join(', ')
        }
      end

      @businesses.uniq! {|b| b['id'] }

      @businesses
    end

    def offences
      return @offences if @offences

      @offences = geocoded.map do |r|
        {
          'business_id' => md5(id(r)),
          'date'        => Date.parse(r['date_of_conviction']),
          'link'        => r['link'],
          'description' => r['nature_of_offence'],
          'severity'    => 'major',
        }
      end
    end
  end
end
