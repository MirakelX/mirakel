# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ActiveRecord::Base
  has_many :lists, foreign_key: 'user_id'
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
    :validatable, :timeoutable, :token_authenticatable 

  validates :name,
    presence: true,
    uniqueness: true,
    format: {with: /^[a-z0-9A-Z_\-]+$/i }

  validates :org, format: {with: /^[a-z0-9A-Z_\-]*$/i }

  before_save :ensure_authentication_token

  before_create :create_dumb
  before_destroy { |record| List.destroy_all( "user_id=#{record.id}") }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :org, :name
  # attr_accessible :title, :body
  def username
    self.email
  end

  def create_dumb
    self.org=self.name if self.org==""
    `echo "#{self.name}\n#{self.org}" |  data/add_user.sh`
  end
end


