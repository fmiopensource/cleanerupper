require File.join(File.dirname(__FILE__), 'test_helper')

Cleaner::Data.dictionaries = {
  :words => ["scramble_test", "remove_test", "replace_test", "custom_test", "default_test"],
  :animals => ["cat_test", "dog_test", "fish_test"],
  :furniture => ["bed_test", "chair_test"]
}

class Widget < ActiveRecord::Base
  set_table_name :widgets
  clean :body
end

class ReplaceWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :body, :with => :replace
end

class RemoveWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :body, :title, :with => :remove
end

class ScrambleWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :title, :with => :scramble
end

class CustomWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :body, :title, :with => :custom_function

  def custom_function(value, dict)
    return "Custom Value: #{value}"
  end
end

class CallbackWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :body, :with => :scramble, :callback => :callback_method

  def callback_method
    self.title = "CALLBACK"
    true
  end
end

class FalseCallbackWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :body, :with => :scramble, :callback => :callback_method

  def callback_method
    self.title = "CALLBACK"
    false
  end
end

class CustomDictWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :body, :with => :scramble, :dictionary => :animals
end

class MultiDictWidget < ActiveRecord::Base
  set_table_name :widgets
  clean :body, :with => :scramble, :dictionary => [:animals, :furniture]
end

class CleanerupperTest < Test::Unit::TestCase

  def test_automatically_replace
    str = "cleanerupper replace_test test"
    w = ReplaceWidget.new(:body => str.dup)
    w.save
    w = ReplaceWidget.find(w.id)
    assert w.body != str
    assert w.body.length == str.length
  end

  def test_automatically_remove
    str = "cleanerupper remove_test test"
    w = RemoveWidget.new(:body => str.dup, :title => str.dup)
    w.save
    w = RemoveWidget.find(w.id)
    assert w.body != str
    assert w.body == "cleanerupper  test"
    assert w.title != str
    assert w.body == "cleanerupper  test"
  end

  def test_automatically_scramble
    str = "cleanerupper scramble_test test"
    w = ScrambleWidget.new(:title => str.dup)
    w.save
    w = ScrambleWidget.find(w.id)
    assert w.title != str
    assert w.title.split(//).sort == str.split(//).sort
  end

  def test_cleanerupper_custom_method
    title = "cleanerupper remove_test title"
    body = "cleanerupper scramble_test body"

    w = CustomWidget.new({:body => body.dup, :title => title.dup})
    w.save
    w = CustomWidget.find(w.id)

    assert w.title != title
    assert w.title == "Custom Value: cleanerupper remove_test title"

    assert w.body != body
    assert w.body == "Custom Value: cleanerupper scramble_test body"
  end

  def test_cleanerupper_custom_callback
    body = "cleanerupper custom_test body"
    w = CallbackWidget.new(:body => body.dup)
    w.save
    w = CallbackWidget.find(w.id)
    assert w.title == "CALLBACK"
  end

  def test_cleanerupper_custom_callback_returns_false
    body = "cleanerupper custom_test body"
    w = FalseCallbackWidget.new(:body => body.dup)
    w.save
    assert w.body == body
    assert w.id == nil
  end

  def test_cleanerupper_default_method
    title = "cleanerupper default_test body"
    w = ScrambleWidget.new(:title => title.dup)
    w.save
    w = ScrambleWidget.find(w.id)
    assert w.title != title
    assert w.title.split(//).sort == title.split(//).sort
  end

  def test_cleanerupper_custom_dictionary
    body = "dog_test bird_test fish_test"
    w = CustomDictWidget.new(:body => body.dup)
    w.save
    w = CustomDictWidget.find(w.id)
    assert w.body != body
    assert w.body.include?("bird_test")
  end

  def test_multiple_dictionaries
    body = "dog_test regular_test bed_test"
    w = MultiDictWidget.new(:body => body.dup)
    w.save
    w = MultiDictWidget.find(w.id)
    assert w.body != body
    assert w.body.include?("regular_test")
    assert !w.body.include?("dog_test")
    assert !w.body.include?("bed_test")
  end
end
