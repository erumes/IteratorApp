require 'rails_helper'
include Constants

RSpec.describe EventsInIteratorService, type: :request do
  let(:user) { FactoryBot.create(:users) }
  let(:body_A) { { "email": user.email, "eventName": "A" } }
  let(:body_B) { { "email": user.email, "eventName": "B" } }
  let(:service_A) { described_class.new({event_type: "A", user_email: user.email}) }
  let(:service_B) { described_class.new({event_type: "B", user_email: user.email}) }

  context "#call" do
    it "should return 200 response for valid API key for event A" do
      resp = {
        "msg": "Event created",
        "code": "Success",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_EVENTS_URL)
        .with(body: body_A.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp.to_json, status: 200)
      iterator = service_A.call
      expect(iterator).to eq 200
    end

    it "should return 200 response for valid API key for event B" do
      resp = {
        "msg": "Event created",
        "code": "Success",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_EVENTS_URL)
        .with(body: body_B.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp.to_json, status: 200)
      iterator = service_B.call
      expect(iterator).to eq 200
    end

    it "should return 401 response for invalid API key for event A" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_EVENTS_URL)
        .with(body: body_A.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)
      iterator = service_A.call
      expect(iterator).to eq 401
    end

    it "should return 401 response for invalid API key for event B" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_EVENTS_URL)
        .with(body: body_B.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)
      iterator = service_B.call
      expect(iterator).to eq 401
    end
  end
end