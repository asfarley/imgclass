## The User class represents workers who will perform image classification and labelling.
# Users may classify images; they cannot create new image sets or assign jobs to other users.

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :image_label_sets
  has_many :jobs
end
