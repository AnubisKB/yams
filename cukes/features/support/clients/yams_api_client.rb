class YamsApiClient
    def index
        @response = RestClient.get "#{yams_url}"
    rescue RestClient::Exception => e
        @response = e.response
    end

    def get(message_id)
        @response = RestClient.get "#{yams_url}/#{message_id}"
    rescue RestClient::Exception => e
        @response = e.response
    end

    def create(payload)
        @response = RestClient.post "#{yams_url}/", payload.to_json, content_type: 'application/json'    
    rescue RestClient::Exception => e
        @response = e.response
    end

    def delete(message_id)
        @response = RestClient.delete "#{yams_url}/#{message_id}"
    rescue RestClient::Exception => e
        @response = e.response
    end

    def response_body
        @response.body
    end

    def response_code
        @response.code
    end

    private

    def yams_url
        "localhost:8080/yams"
    end
end