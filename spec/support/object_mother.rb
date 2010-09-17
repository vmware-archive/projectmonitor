
module ObjectMother
  def new_user(overrides = {})
    User.new({:login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69'}.merge(overrides))
  end

  def create_user(overrides = {})
    user = new_user(overrides)
    user.save!
    user
  end
end

