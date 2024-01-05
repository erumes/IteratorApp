require 'rails_helper'
include Constants

# stub_request from Webmock is used to mock API responses.
# We are testing various APIs of Iterator which requires mocking the response.
RSpec.describe EventsController, type: :controller do
  let(:user) { FactoryBot.create(:users) }
  let(:campaign_id) { Faker::Number.number }

  before do
    allow_any_instance_of(User).to receive(:save_user_in_iterator).and_return(true)
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow_any_instance_of(EventsController).to receive(:get_campaign_id).and_return(campaign_id)
    resp = {
      "msg": "Event created",
      "code": "Success",
      "params": {}
    }
    stub_request(:post, ITERABLE_URL+ITERABLE_EVENTS_URL)
      .with(body: body.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
      .to_return(body: resp.to_json, status: 200)
  end

  context "#create event A" do
    let(:body) { { "email": user.email, "eventName": "A" } }
    let(:params) { { event_type: "A", user_email: user.email } }

    it "should create event A in iterator" do
      post :create, params: params
      expect(flash.now[:success]).to include("Event A created in iterator!!")
    end

    it "should not create event A in iterator if api fails" do
      resp = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_EVENTS_URL)
        .with(body: body.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp.to_json, status: 401)

      post :create, params: params
      expect(flash.now[:error]).to include("Event A creation failed in iterator.")
    end
  end

  context "#create event B" do
    let(:body) { { "email": user.email, "eventName": "B" } }
    let(:params) { { event_type: "B", user_email: user.email } }
    let(:body_email) { { "campaignId": campaign_id, "recipientEmail": user.email } }

    it "should create event B in iterator and send email" do
      resp_email = {
        "msg": "Email Sent",
        "code": "Success",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_EMAIL_URL)
        .with(body: body_email.to_json, headers: { 'Content-Type' => "application/json", 'Api-Key' => Rails.application.credentials.iterator_api_key })
        .to_return(body: resp_email.to_json, status: 200)

      post :create, params: params
      expect(flash.now[:success]).to include("Event B created in iterator and email sent to #{user.email}!!")
    end

    it "should create event B in iterator but should not send email due to API failure" do
      resp_email = {
        "msg": "Invalid API key",
        "code": "BadApiKey",
        "params": {}
      }
      stub_request(:post, ITERABLE_URL+ITERABLE_EMAIL_URL)
        .with(body: body_email.to_json, headers: { 'Content-Type' => "application/json" })
        .to_return(body: resp_email.to_json, status: 401)

      post :create, params: params
      expect(flash.now[:error]).to include("Event B created in iterator but email failed.")
    end
  end
end