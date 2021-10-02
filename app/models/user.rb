class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token 
  
  has_many :microposts, dependent: :destroy #с удалением пользователя удаляются все его сообщения

  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy 
  
  has_many :following, through: :active_relationships, source: :followed 
  has_many :followers, through: :passive_relationships, source: :follower

  before_save :downcase_email 
  before_create :create_activation_digest

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  mount_uploader :avatar, AvatarUploader
  validates :name, presence: true, length: { maximum: 50 } 
  validates :email, presence: true, length: { maximum: 255 }, 
                                    format: { with: VALID_EMAIL_REGEX }, 
                                    uniqueness: { case_sensitive: false }
  
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true 

  # Returns the hash digest of the given string. 
  def User.digest(string) 
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost 
    BCrypt::Password.create(string, cost: cost) 
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # Активация аккаунта. 
  def activate 
    update_attribute(:activated, true) 
    update_attribute(:activated_at, Time.zone.now) 
  end 

  # Добавить активацию email. 
  def send_activation_email 
    UserMailer.account_activation(self).deliver_now 
  end

  def create_reset_digest 
    self.reset_token = User.new_token 
    update_attribute(:reset_digest, User.digest(reset_token)) 
    update_attribute(:reset_sent_at, Time.zone.now) 
  end 

  # Отправить письмо с повтором пароля. 
  def send_password_reset_email 
    UserMailer.password_reset(self).deliver_now 
  end

  # Возвращает истину, если срок действия сброса пароля истёк
  def password_reset_expired? 
    reset_sent_at < 2.hours.ago 
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # Подписанные.
  def follow(other_user) 
    active_relationships.create(followed_id: other_user.id) 
  end 

  # Неподписанные. 
  def unfollow(other_user) 
    active_relationships.find_by(followed_id: other_user.id).destroy 
  end 

  # Возвращает тру при подписке текущего пользователя на другого пользователя. 
  def following?(other_user) 
    following.include?(other_user) 
  end

  private

  # Приводит почту к нижнему регистру. 
  def downcase_email 
    self.email = email.downcase 
  end 

  # Создаёт и назначает токен активации и дайджест. 
  def create_activation_digest 
    self.activation_token = User.new_token 
    self.activation_digest = User.digest(activation_token) 
  end
end
