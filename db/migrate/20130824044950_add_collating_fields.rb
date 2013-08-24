class AddCollatingFields < ActiveRecord::Migration
  def up
    add_column :fields, :unicode_casemap, :string
    add_column :fields, :ascii_casemap, :string

    transaction do

      Field.all.each do |field|
        field.ascii_casemap = Comparators::ASCIICasemap.prepare(field.value)
        field.unicode_casemap = Comparators::UnicodeCasemap.prepare(field.value)
        field.save!
      end

    end

    change_column :fields, :unicode_casemap, :string, null: false
    change_column :fields, :ascii_casemap, :string, null: false
  end

  def down
    remove_column :fields, :unicode_casemap
    remove_column :fields, :ascii_casemap
  end
end
