require 'uri'
require 'net/http'
require 'net/http/digest_auth'
module RubiconApiClient
    class RubiconClient
        @@host = 'http://api.rubiconproject.com'


        def whens
            ['today', 'yesterday', 'this week', 'last week', 'this month', 'last month', 'this year', 'last 7', 'last 30', 'all']
        end


        def initialize(id, key, secret)
            @id = id
            @key = key
            @secret = secret
        end

        def execute(path)
            puts path

            uri = URI.parse @@host
            uri.user = @key
            uri.password = @secret

            net = Net::HTTP.new uri.host    
            req = Net::HTTP::Get.new path

            res = net.request req

            auth = Net::HTTP::DigestAuth.new.auth_header uri, res['www-authenticate'], 'GET'
            req = Net::HTTP::Get.new path
            req.add_field 'Authorization', auth
            net.request req
        end

        def compose_arguments(hash)
            args = []
            hash.each_key do |key|
                hash[key] = [hash[key]] if !hash[key].is_a?(Array)
                args << "#{key}=#{hash[key].join(',')}" unless hash[key][0] == '' || hash[key][0].nil?
            end
            URI.escape '?'+args.join('&')
        end

        def parse_date(date_range_splat)
            args = {}
            if whens.include? date_range_splat[0].to_s
                args['when'] = date_range_splat[0].to_s
            elsif date_range_splat.length == 2
                args['start'] = Date.parse(date_range_splat[0].to_s).to_s
                args['end'] = Date.parse(date_range_splat[0].to_s).to_s
            end
            args
        end
    end

    class Seller < RubiconClient
        def zone_performance_report(site_ids='',*date_range)

            args = parse_date date_range

            args['site_id'] = site_ids
            
            path = "/seller/api/ips/v1/reports/zone/performance/#{@id}/#{compose_arguments args}"
            execute(path)
        end
        
        def ad_hoc_performance_report(dimensions, measures, currency=nil, *date_range)
            possible_dims = ['date','site','zone','country','keyword','campaign','campaign_relationship','partner','agency']
            possible_measures = ['paid_impressions','total_impressions','revenue','ecpm','rcpm','fill_rate']

            args = parse_date date_range
            args['currency'] = currency
            args['dimensions'] = Array.new
            args['measures'] = Array.new
            
            dimensions.each { |dim| args['dimensions'] << dim if possible_dims.include? dim } if dimensions.is_a? Array
            measures.each { |measure| args['measures'] << measure if possible_measures.include? measure } if measures.is_a? Array

            path = "/seller/api/ips/v2/reports/performance/#{@id}/#{compose_arguments args}"
            execute(path)
        end

        def execute(path)
            super path
        end
    end
end
