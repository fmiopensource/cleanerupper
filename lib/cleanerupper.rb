=begin
  Author........: Mike Trpcic
  Last Updated..: March 28, 2010

  Description:  Cleans all inappropriate data from the database
                                                               
  (c) Fluid Media Inc.
=end

module Cleaner
  extend self
  #The Dictionary class contains all words that are used by the Cleaner.  It also contains other
  #integral components, such as the replacement characters for the `replace` method.
  class Data
    cattr_accessor :file, :replacement_chars, :cleaner_methods, :dictionaries
   
    @@dictionaries = {} 
    #Use the default dictionary if one wasn't defined by the user
    if File.exists?(File.join(RAILS_ROOT, '/config/dictionary.yml'))
      @@file  = File.join(RAILS_ROOT, '/config/dictionary.yml')
    elsif File.exists?(File.join(File.dirname(__FILE__), '../dictionary.yml'))
      @@file  = File.join(File.dirname(__FILE__), '../dictionary.yml')
    else
      @@file  = nil
    end
    @@cleaner_methods = [:scramble, :replace, :remove]
    @@replacement_chars = ['*', '@', '!', '$', '%', '&']
    unless(@@file.nil?)
      data = YAML.load_file(@@file)
    else
      data = {}
    end
    data.each do |k, v|
      @@dictionaries[k.to_sym] = v.split(" ")
    end
  end

  module ActiveRecord
    def self.included(base)
      base.extend Extension
    end

    #Append the following methods to the ActiveRecord::Base class
    def bind(column, method, dictionary, callback = nil)
      #debugger
      old_value = read_attribute(column)
      to_save = true

      unless old_value.nil?
        if Cleaner::Data.cleaner_methods.include?(method.to_sym)
          new_value = Cleaner.send(method.to_sym, old_value.dup, dictionary)
        else
          new_value = self.send(method, old_value.dup, dictionary)
        end
        unless new_value == old_value
          to_save = callback.nil? ? true : self.send(callback) == false ? false : true
          write_attribute(column, new_value) if to_save
        end
      end
      return to_save
    end
  end

  module Extension

    #These are methods that can be called in the same manner that
    #before_save filters are called
    def clean(*args)
      params = args[-1].is_a?(Hash) ? args[-1] : {}
      attributes = args[0..-1] if params
      with = params.has_key?(:with) ? params[:with] : :scramble
      callback = params.has_key?(:callback) ? params[:callback] : nil
      dictionary = params.has_key?(:dictionary) ? params[:dictionary] : :words
      attributes.each do |attribute|
        before_save {|m| m.bind(attribute, with, dictionary, callback)}
      end
    end
  end

  #Define all your actual manipulation methods here:

  #This method scrambles data by rearranging the letters.
  def scramble(value, dict)
    Cleaner::Data.dictionaries[dict].each do |word|
      value.to_s.gsub!(/#{word}/, word.split(//).shuffle.join(''))
    end
    value
  end

  #This method removes selected words from the string and replaces them
  #with nothing
  def remove(value, dict)
    Cleaner::Data.dictionaries[dict].each do |word|
      value.to_s.gsub!(/#{word}/, "")
    end
    value
  end

  #This method removes selected words from the string and replaces them
  #with 'swear' characters,such as '#$@!%&'
  def replace(value, dict)
    Cleaner::Data.dictionaries[dict].each do |word|
      value.to_s.gsub!(/#{word}/, word.split(//).map{|c| c = Cleaner::Data.replacement_chars.shuffle[0]}.join(''))
    end
    value
  end
end
