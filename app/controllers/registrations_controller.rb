class RegistrationsController < Devise::RegistrationsController
  def create
    super do
      if resource.persisted?
        response = UsersInIteratorService.new({user_id: resource.id, user_email: resource.email}).call
        if response == 200
          flash.now[:success] = "User #{resource.email} created in iterable!!"
        else
          flash.now[:error] = "User #{resource.email} creation failed in iterable."
        end
      end
    end
  end
end