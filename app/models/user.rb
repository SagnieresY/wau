class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :organisation, optional: true

  after_create :send_welcome_email

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end
  def self.to_csv(organisation)
      attributes = %w{id created_at email}
      CSV.generate(headers: true) do |csv|
        csv << attributes

        organisation.users.each do |user|
          csv << attributes.map{ |attr| user.send(attr) }
        end
      end
  end
end
