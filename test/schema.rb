ActiveRecord::Schema.define(:version => 1) do
  create_table :widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end

  create_table :words, :force => true do |t|
    t.column :word, :string, :limit => 100
  end
end
