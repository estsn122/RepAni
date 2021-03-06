class CreateTerms < ActiveRecord::Migration[6.0]
  def change
    create_table :terms do |t|
      t.integer :year, null: false
      t.integer :season, null: false
      t.string :season_ja, null: false
      t.boolean :now, null: false, default: false
      t.timestamps
    end

    add_index :terms, [:year, :season], unique: true
  end
end
