require 'activerecord'
require 'cleanerupper'
ActiveRecord::Base.send(:include, Cleaner::ActiveRecord)