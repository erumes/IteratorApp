class SetCampaignIdService
  include Constants, Connection
  attr_accessor :user_id, :user

  def initialize(options)
    @user_id = options[:user_id]
    @user = User.find(user_id)
  end

  def call
    temp_resp = create_template
    if temp_resp == 200
      temp_status, temp_body = get_template_id
      if temp_status == 200 && temp_body["templates"].size > 0
        template_id = temp_body["templates"][0]["templateId"].to_i
        camp_status, camp_body = create_campaign(template_id)
        if camp_status == 200 && camp_body["campaignId"].present?
          return camp_body["campaignId"].to_i
        end
      end
    end
    nil
  rescue => e
    p e
    nil
  end

  private

  def create_template
    body = {
      "clientTemplateId": user_id.to_s,
      "name": "Event_B_Template",
      "fromEmail": "company@mailinator.com",
      "subject": "Notification for Event B Trigger",
      "plainText": "Dear #{user.first_name.presence || user.email}, Event B was triggered.",
      "messageMedium": {}
    }
    response = connection(:post, ITERABLE_URL+ITERABLE_TEMPLATE_CREATE_URL, body)
    response.code.to_i
  rescue => e
    p e
    500
  end

  def get_template_id
    url = ITERABLE_URL + ITERABLE_TEMPLATE_GET_URL + "?clientTemplateId=" + user_id.to_s
    response = connection(:get, url)
    [response.code.to_i, JSON.parse(response.body).with_indifferent_access]
  rescue => e
    p e
    [500, {}]
  end

  def create_campaign(template_id)
    body = {
      "name": "Event B Campaign",
      "listIds": [],
      "templateId": template_id,
    }
    response = connection(:post, ITERABLE_URL+ITERABLE_CAMPAIGN_URL, body)
    [response.code.to_i, JSON.parse(response.body).with_indifferent_access]
  rescue => e
    p e
    [500, {}]
  end
end
