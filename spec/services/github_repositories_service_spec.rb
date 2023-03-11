require 'rails_helper'

RSpec.describe GithubRepositoriesService, type: :service do
  def stub_request(status:, body:)
    allow_any_instance_of(Faraday::Connection).to receive(:get)
      .with('/search/repositories', { q: 'test in:name is:public', page: 1 })
      .and_return(
        double(
          'Faraday::Response',
          status:,
          body: body.to_json,
          headers: { 'link' => 'rel="next"' }
        )
      )
  end

  context 'when request is successful' do
    before do
      stub_request(status: 200, body: { items: [{ name: 'test', owner: 'test_owner' }] })
    end

    it 'returns a list of repositories' do
      response, = described_class.call(query: 'test')

      expect(response.first['name']).to eq 'test'
    end
  end

  context 'when request fails' do
    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .and_raise(Faraday::Error)
    end

    it 'raises the error' do
      expect { described_class.call(query: 'fail') }
        .to raise_error(RepositoriesError)
    end
  end

  context 'when query param is empty' do
    it 'returns and empty array' do
      response, = described_class.call(query: '')

      expect(response).to be_empty
    end
  end

  context 'when items do not exist' do
    before do
      stub_request(status: 200, body: { foo: 'bar' })
    end

    it 'returns an empty array' do
      response, = described_class.call(query: 'test')

      expect(response).to be_empty
    end
  end
end
