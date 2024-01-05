class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_commit :save_user_in_iterator, on: :create

  private

  # This is to save user in Iterator after user creation/signup
  def save_user_in_iterator
    UsersInIteratorService.new({user_id: id, user_email: email}).call
  end
end
