module Australia
  class WA
    include Source

    description 'Western Australia Department of Health list of food offenders'

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
end
