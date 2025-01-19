require "net/http"
require "net/https"

class EmployeeService
  BASE_API_URL = "https://dummy-employees-api-8bad748cda19.herokuapp.com/employees".freeze

  def fetch_all(page = nil)
    uri = URI(BASE_API_URL)
    uri.query = { page: page }.to_query if page.present?
    fetch_data(uri)
  end

  def fetch(employee_id)
    uri = URI("#{BASE_API_URL}/#{employee_id}")
    fetch_data(uri)
  end

  def create(employee_params)
    uri = URI(BASE_API_URL)
    make_request(:post, uri, employee_params.to_json)
  end

  def update(employee_id, employee_params)
    uri = URI("#{BASE_API_URL}/#{employee_id}")
    make_request(:put, uri, employee_params.to_json)
  end

  private

  def fetch_data(uri)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse response from #{uri}: #{e.message}")
    {}
  end

  def make_request(http_method, uri, body)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    request = build_request(http_method, uri)
    request.body = body

    response = http.request(request)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse API response: #{e.message}")
    {}
  rescue StandardError => e
    Rails.logger.error("HTTP request failed: #{e.message}")
    raise
  end

  def build_request(http_method, uri)
    request_class = case http_method
                    when :post then Net::HTTP::Post
                    when :put then Net::HTTP::Put
                    else raise ArgumentError, "Unsupported HTTP method: #{http_method}"
                    end

    request_class.new(uri, "Content-Type" => "application/json")
  end
end
