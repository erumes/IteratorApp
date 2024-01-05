# This class implements functionality to create a campaign in Iterator.
# campaign creation will return a campaign id which is required in Email trigger API
# In case of Exceptions, method call will return 500
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

  # Step 1 - Create an Email Template
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

  # Step 2 - Get the Template Id of previously created template.
  # Using clientTemplateId it will return all templates.
  # In this case it will return a collection of 1 template, so we select the first one on line 18
  def get_template_id
    url = ITERABLE_URL + ITERABLE_TEMPLATE_GET_URL + "?clientTemplateId=" + user_id.to_s
    response = connection(:get, url)
    [response.code.to_i, JSON.parse(response.body).with_indifferent_access]
  rescue => e
    p e
    [500, {}]
  end

  # Step 3 - Use the template id retrieved in previous step for creating campaign.
  # This API will return Campaign id in response body.
  # We will then return the campaign id to be stored in the user's session
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
