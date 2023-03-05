class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :trackable

  has_many :items

  def is_me?
    email == 'th.patris@gmail.com'
  end

  def counter
    self.items.to_show_today.count
  end
end
