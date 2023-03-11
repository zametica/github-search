class GithubRepositoriesService
  def self.call(query:, page: 1)
    new(query, page).call
  end

  def initialize(query, page)
    @query = query
    @page = page || 1
  end

  # it would be nice if ETag header was available on search to prevent hitting the rate limit
  # otherwise it doesn't seem right to wait for the limit reset and postpone the request
  # several solutions possible but neither one seems to be perfect (check README.md)
  def call
    return [[], page] if query.blank?

    response = connection.get('/search/repositories', { q: "#{query} in:name is:public", page: })
    parsed_response = JSON.parse(response.body)
    next_page = page.to_i + 1 if response.headers['link']&.include?('rel="next"')
    [parsed_response['items'] || [], next_page]
  rescue Faraday::Error, JSON::ParserError => e
    raise RepositoriesError, e.message
  end

  private

  attr_reader :query, :page

  def connection
    @connection ||= Faraday.new(
      url: 'https://api.github.com',
      headers:,
      params: {
        per_page: 100
      }
    ) { |f| f.response :raise_error }
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/vnd.github+json',
      'Authorization' => "Bearer #{Rails.application.secrets.github[:token]}",
      'X-GitHub-Api-Version' => '2022-11-28',
      'User-Agent' => 'Github Search APP'
    }
  end
end
