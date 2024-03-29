require 'rails_helper'
include Constants

# stub_request from Webmock is used to mock API responses.
# We are testing various APIs of Iterator which requires mocking the response.
RSpec.describe UsersInIteratorService, type: :request do
  let(:user) { FactoryBot.create(:users) }
  let(:body) { { "email": user.email, "userId": user.id } }
  let(:service) { described_class.new({user_id: user.id, user_email: user.email}) }

  context "#call" do
    it "should return 200 response for valid API key" do
      resp = {
        "msg": "User created",
        "code": "Success",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_USERS_URL)
        .with(body: body.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp.to_json, status: 200)
      iterator = service.call
      expect(iterator).to eq 200
    end

    it "should return 401 response for invalid API key" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_USERS_URL)
        .with(body: body.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)
      iterator = service.call
      expect(iterator).to eq 401
    end
  end
end