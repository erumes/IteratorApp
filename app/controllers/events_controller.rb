class EventsController < ApplicationController
  def create
    event_type = params[:event_type]
    response = EventsInIteratorService.new({user_email: current_user.email, event_type: event_type}).call
    if response == 200
      if eligible_event_type.include?(event_type)
        camp_id = get_campaign_id
        return send_email(camp_id) if camp_id
      end
      flash.now[:success] = "Event #{event_type} created in iterator!!"
    else
      flash.now[:error] = "Event #{event_type} creation failed in iterator."
    end
    render turbo_stream: turbo_stream.replace("flash-messages", partial: "layouts/flash_message")
  end

  private

  def eligible_event_type
    ["B"]
  end

  def get_campaign_id
    unless session["iterable_campaign_id"]
      session["iterable_campaign_id"] = SetCampaignIdService.new({user_id: current_user.id}).call
    end
    session["iterable_campaign_id"]
  end

  def send_email(camp_id)
    response = SendEmailService.new({campaign_id: camp_id, user_email: current_user.email}).call
    if response == 200
      flash.now[:success] = "Event #{params[:event_type]} created in iterator and email sent to #{current_user.email}!!"
    else
      flash.now[:error] = "Event #{params[:event_type]} created in iterator but email failed."
    end
    render turbo_stream: turbo_stream.replace("flash-messages", partial: "layouts/flash_message")
  end
end