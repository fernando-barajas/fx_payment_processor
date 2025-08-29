require 'rails_helper'

RSpec.describe User, type: :model do
  it "creates a wallet after user creation" do
    expect { FactoryBot.create(:user) }.to change { Wallet.count }.by(1)
  end
end
