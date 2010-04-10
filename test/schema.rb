ActiveRecord::Schema.define(:version => 1) do
  create_table :widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end

  create_table :replace_widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end

  create_table :remove_widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end

  create_table :scramble_widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end

  create_table :custom_widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end

  create_table :callback_widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end

  create_table :false_callback_widgets, :force => true do |t|
    t.column :title, :string, :limit => 100
    t.column :body, :string
    t.column :author_name, :string, :limit => 100
  end
end