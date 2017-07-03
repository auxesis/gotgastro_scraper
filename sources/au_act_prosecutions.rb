module Australia
  class ACT
    include Source

    description %(Australian Capital Territory Health's register of food offences)

    def url
      'https://api.morph.io/auxesis/act_register_of_food_offences/data.json'
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
          'id'      => md5(r['business_address']),
          'name'    => r['business_name'],
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
          'business_id' => md5(r['business_address']),
          'date'        => Date.parse(r['offence_date']),
          'link'        => "#{r['link']}##{r['id']}",
          'description' => "Penalty: _#{r['imposed_penalty']}_. #{r['offence']}",
          'severity'    => 'major',
        }
      end
    end
  end
end
