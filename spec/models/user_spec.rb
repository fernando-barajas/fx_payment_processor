require 'rails_helper'

RSpec.describe User, type: :model do
  it "creates a wallet after user creation" do
    user = FactoryBot.create(:user)
    expect(user.wallet).to be_present
  end
end
