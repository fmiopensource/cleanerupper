require 'active_record'
require 'cleanerupper'
ActiveRecord::Base.send(:include, Cleaner::ActiveRecord)
