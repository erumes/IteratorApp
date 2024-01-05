require 'rails_helper'
include Constants

# stub_request from Webmock is used to mock API responses.
# We are testing various APIs of Iterator which requires mocking the response.
RSpec.describe SetCampaignIdService, type: :request do
  let(:user) { FactoryBot.create(:users) }
  let(:service) { described_class.new({user_id: user.id}) }

  before do
    allow_any_instance_of(User).to receive(:save_user_in_iterator).and_return(true)
  end
  
  # Testing create_template method only
  context "#create_template" do
    let(:body) { {
      "clientTemplateId": user.id.to_s,
      "name": "Event_B_Template",
      "fromEmail": "company@mailinator.com",
      "subject": "Notification for Event B Trigger",
      "plainText": "Dear #{user.first_name.presence || user.email}, Event B was triggered.",
      "messageMedium": {}
    } }

    it "should return 200 response for valid API key" do
      resp = {
        "msg": "Template created",
        "code": "Success",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_TEMPLATE_CREATE_URL)
        .with(body: body.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp.to_json, status: 200)
      iterator = service.send(:create_template)
      expect(iterator).to eq 200
    end

    it "should return 401 response for invalid API key" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_TEMPLATE_CREATE_URL)
        .with(body: body.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)
      iterator = service.send(:create_template)
      expect(iterator).to eq 401
    end
  end

  # Testing get_template_id method only
  context "#get_template_id" do
    it "should return 200 response for valid API key" do
      resp = {
        "templates":[
          {
            "templateId": 123
          }
        ]
      }
      stub_request(:get, ITERABLE_URL + ITERABLE_TEMPLATE_GET_URL + "?clientTemplateId=" + user.id.to_s)
        .with(headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp.to_json, status: 200)
      iterator = service.send(:get_template_id)
      expect(iterator).to eq [200, JSON.parse(resp.to_json)]
    end

    it "should return 401 response for invalid API key" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:get, ITERABLE_URL + ITERABLE_TEMPLATE_GET_URL + "?clientTemplateId=" + user.id.to_s)
        .with(headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)
      iterator = service.send(:get_template_id)
      expect(iterator).to eq [401, JSON.parse(resp.to_json)]
    end
  end

  # Testing create_campaign method only
  context "#create_campaign" do
    let(:template_id) { Faker::Number.number }
    let(:campaign_id) { Faker::Number.number }
    let(:body) { {
      "name": "Event B Campaign",
      "listIds": [],
      "templateId": template_id,
    } }

    it "should return 200 response for valid API key" do
      resp = {
        "campaignId": campaign_id
      }
      stub_request(:post, ITERABLE_URL + ITERABLE_CAMPAIGN_URL)
        .with(body: body.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp.to_json, status: 200)
      iterator = service.send(:create_campaign, template_id)
      expect(iterator).to eq [200, JSON.parse(resp.to_json)]
    end

    it "should return 401 response for invalid API key" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL + ITERABLE_CAMPAIGN_URL)
        .with(body: body.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)
      iterator = service.send(:create_campaign, template_id)
      expect(iterator).to eq [401, JSON.parse(resp.to_json)]
    end
  end

  # Testing all 3 above APIs using stubs
  context "#call" do
    let(:template_id) { Faker::Number.number }
    let(:campaign_id) { Faker::Number.number }
    let(:body_temp) { {
      "clientTemplateId": user.id.to_s,
      "name": "Event_B_Template",
      "fromEmail": "company@mailinator.com",
      "subject": "Notification for Event B Trigger",
      "plainText": "Dear #{user.first_name.presence || user.email}, Event B was triggered.",
      "messageMedium": {}
    } }
    let(:body_camp) { {
      "name": "Event B Campaign",
      "listIds": [],
      "templateId": template_id,
    } }

    it "should return 200 response for valid API key" do
      resp_temp = {
        "msg": "Template created",
        "code": "Success",
        "params": {}
      }
      resp_id = {
        "templates":[
          {
            "templateId": template_id
          }
        ]
      }
      resp_camp = {
        "campaignId": campaign_id
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_TEMPLATE_CREATE_URL)
        .with(body: body_temp.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp_temp.to_json, status: 200)

      stub_request(:get, ITERABLE_URL + ITERABLE_TEMPLATE_GET_URL + "?clientTemplateId=" + user.id.to_s)
        .with(headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp_id.to_json, status: 200)

      stub_request(:post, ITERABLE_URL + ITERABLE_CAMPAIGN_URL)
        .with(body: body_camp.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp_camp.to_json, status: 200)

      iterator = service.call
      expect(iterator).to eq campaign_id.to_i
    end

    it "should return 401 response for invalid API key" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_TEMPLATE_CREATE_URL)
        .with(body: body_temp.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)

      stub_request(:get, ITERABLE_URL + ITERABLE_TEMPLATE_GET_URL + "?clientTemplateId=" + user.id.to_s)
        .with(headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)

      stub_request(:post, ITERABLE_URL + ITERABLE_CAMPAIGN_URL)
        .with(body: body_camp.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)

      iterator = service.call
      expect(iterator).to eq nil
    end
  end
end