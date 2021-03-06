require 'rails_helper'
RSpec.describe 'admin/animes/terms', type: :system do
  describe '放送時期一覧' do
    let!(:anime) { create(:anime) }
    let!(:term1) { create(:term, year: 2019, season: 1) }
    let!(:term2) { create(:term, year: 2020, season: 1) }
    let!(:term3) { create(:term, year: 2020, season: 2) }
    let!(:admin_user) { create(:user, role: 'admin') }
    before do
      create(:anime_term, anime_id: anime.id, term_id: term1.id)
      create(:anime_term, anime_id: anime.id, term_id: term2.id)
      create(:anime_term, anime_id: anime.id, term_id: term3.id)
      admin_login_as(admin_user)
    end
    it '表示値が正しい' do
      visit admin_anime_path(anime)
      trs = all('#term-detail tbody tr')
      expect(trs[0]).to have_content(term1.year)
      expect(trs[0]).to have_content(term1.season_ja)
      expect(trs[0]).to have_content(Term.seasons.invert[term1.season])
      expect(trs.length).to eq 3
    end
  end
  describe '放送時期編集' do
    let!(:anime) { create(:anime) }
    let!(:term1) { create(:term, year: 2019, season: 4) }
    let!(:term2) { create(:term, year: 2020, season: 3) }
    let!(:admin_user) { create(:user, role: 'admin') }
    before do
      create(:anime_term, anime_id: anime.id, term_id: term1.id)
      create(:anime_term, anime_id: anime.id, term_id: term2.id)
      admin_login_as(admin_user)
    end
    context '正常処理' do
      it '登録済の放送時期を更新' do
        visit edit_admin_anime_terms_path(anime)
        year = 2018
        season = '夏'
        fill_in 'anime_terms_attributes_0_year', with: year
        select season, from: 'anime_terms_attributes_0_season'
        click_on '更新'
        expect(current_path).to eq admin_anime_path(anime)
        trs = all('#term-detail tbody tr')
        expect(trs[0]).to have_content(year)
        expect(trs[0]).to have_content(season)
        expect(trs.length).to eq 2
      end
      it '1行追加で更新できる' do
        visit edit_admin_anime_terms_path(anime)
        year = 2018
        season = '秋'
        click_on '1行追加'
        (all('.term-year')[2]).set(year)
        within all('.nested-fields')[2] do
          select season
        end
        click_on '更新'
        trs = all('#term-detail tbody tr')
        expect(trs[0]).to have_content(year)
        expect(trs[0]).to have_content(season)
        expect(trs.length).to eq 3
      end
      it '放送時期を削除できる' do
        visit edit_admin_anime_terms_path(anime)
        within all('.nested-fields')[0] do
          click_on '削除'
        end
        click_on '更新'
        expect(current_path).to eq admin_anime_path(anime)
        trs = all('#term-detail tbody tr')
        expect(trs[0]).to have_content(term2.year)
        expect(trs[0]).to have_content(term2.season_ja)
        expect(trs.length).to eq 1
      end
    end
    context '特殊処理' do
      it '追加行の年を空欄にしたとき、その行は登録されない' do
        visit edit_admin_anime_terms_path(anime)
        click_on '1行追加'
        within all('.nested-fields')[2] do
          select '春'
        end
        click_on '更新'
        expect(current_path).to eq admin_anime_path(anime)
        trs = all('#term-detail tbody tr')
        expect(trs[0]).to have_content(term1.year)
        expect(trs[0]).to have_content(term1.season_ja)
        expect(trs[1]).to have_content(term2.year)
        expect(trs[1]).to have_content(term2.season_ja)
        expect(trs.length).to eq 2
      end
      it '追加行の季節を空欄にしたとき、その行は登録されない' do
        visit edit_admin_anime_terms_path(anime)
        click_on '1行追加'
        (all('.term-year')[2]).set(2018)
        click_on '更新'
        expect(current_path).to eq admin_anime_path(anime)
        trs = all('#term-detail tbody tr')
        expect(trs[0]).to have_content(term1.year)
        expect(trs[0]).to have_content(term1.season_ja)
        expect(trs[1]).to have_content(term2.year)
        expect(trs[1]).to have_content(term2.season_ja)
        expect(trs.length).to eq 2
      end
      it '登録済の年を空欄にしたとき、その行は削除される' do
        visit edit_admin_anime_terms_path(anime)
        fill_in 'anime_terms_attributes_0_year', with: ''
        click_on '更新'
        trs = all('#term-detail tbody tr')
        expect(trs[0]).to have_content(term2.year)
        expect(trs[0]).to have_content(term2.season_ja)
        expect(trs.length).to eq 1
      end
    end
  end
end

