require 'spec_helper'

module AV
  describe Util do
    describe :uri_or_nil do
      it 'returns nil for nil' do
        expect(AV::Util.uri_or_nil(nil)).to be_nil
      end

      it 'returns a URI object unchanged' do
        uri = URI.parse('http://example.org/foo/bar')
        expect(AV::Util.uri_or_nil(uri)).to be(uri)
      end

      it 'returns an equivalent URI for a URL string' do
        url = 'http://example.org/foo/bar'
        expect(AV::Util.uri_or_nil(url)).to eq(URI.parse(url))
      end

      it 'raises an error for garbage' do
        expect { AV::Util.uri_or_nil('I am not a url') }.to raise_error(URI::InvalidURIError)
      end
    end

    describe :do_get do
      it 'accepts a string URL' do
        url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
        body = File.read('spec/data/b11082434.html')
        stub_request(:get, url).to_return(status: 200, body: body)

        result = AV::Util.do_get(url)
        expect(result).to eq(body.scrub)
      end

      it 'accepts a URI' do
        url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
        body = File.read('spec/data/b11082434.html')
        stub_request(:get, url).to_return(status: 200, body: body)

        uri = URI.parse(url)
        result = AV::Util.do_get(uri)
        expect(result).to eq(body.scrub)
      end

      it 'sends a Chrome user-agent header' do
        expected_ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36'

        url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
        body = File.read('spec/data/b11082434.html')
        stub_request(:get, url).with(headers: { 'User-Agent' => expected_ua }).to_return(status: 200, body: body)

        uri = URI.parse(url)
        result = AV::Util.do_get(uri)
        expect(result).to eq(body.scrub)
      end

      it "raises #{RestClient::Exception} in the event of an invalid response" do
        aggregate_failures 'responses' do
          [207, 400, 401, 403, 404, 405, 418, 451, 500, 503].each do |code|
            url = "http://example.edu/#{code}"
            stub_request(:get, url).to_return(status: code)

            expect { AV::Util.do_get(url) }.to raise_error(RestClient::Exception)
          end
        end
      end

      it 'returns nil for errors when ignore_errors is true' do
        aggregate_failures 'responses' do
          [207, 400, 401, 403, 404, 405, 418, 451, 500, 503].each do |code|
            url = "http://example.edu/#{code}"
            stub_request(:get, url).to_return(status: code)

            body = AV::Util.do_get(url, ignore_errors: true)
            expect(body).to be_nil
          end
        end
      end
    end
  end
end
