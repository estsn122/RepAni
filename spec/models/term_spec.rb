require 'rails_helper'

RSpec.describe Term, type: :model do
  it '年がないと無効' do
    term = build(:term, year:'')
    term.valid?
    expect(term.errors).to be_added(:year, :blank)
  end
  it '季節がないと無効' do
    term = build(:term, season:'')
    term.valid?
    expect(term.errors).to be_added(:season, :blank)
  end
end
