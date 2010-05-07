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
    data.each do |name, words|
      @@dictionaries[name.to_sym] = words.split(" ")
    end
  end

  module ActiveRecord
    def self.included(base)
      base.extend Extension
    end

    #Append the following methods to the ActiveRecord::Base class
    def bind(column, method, dictionary, callback = nil, match_case)
      dictionary = [dictionary].flatten.map{|dict| Cleaner::Data.dictionaries.has_key?(dict) ? Cleaner::Data.dictionaries[dict] : self.send(dict)}.flatten.uniq
      old_value = read_attribute(column)
      to_save = true
      method = method.to_sym
      unless old_value.nil?
        if Cleaner::Data.cleaner_methods.include?(method)
          new_value = Cleaner.send(method, old_value.dup, dictionary, match_case)
        else
          new_value = Cleaner.send(:custom_clean, old_value.dup, dictionary, match_case, self.method(method))
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
      last_argument = args[-1]
      params        = last_argument.is_a?(Hash) ? last_argument : {}
      attributes    = args[0..-1] if params
      with          = params.has_key?(:method)     ? params[:method]     : :scramble
      callback      = params.has_key?(:callback)   ? params[:callback]   : nil
      dictionary    = params.has_key?(:dictionary) ? params[:dictionary] : :words
      match_case    = params.has_key?(:match_case) ? params[:match_case] : false
      attributes.each do |attribute|
        before_save {|model| model.bind(attribute, with, dictionary, callback, match_case)}
      end
    end
  end

  #Define all your actual manipulation methods here:

  #This is a wrapper method for custom cleaning methods defined by a user
  def self.custom_clean(value, dict, match, func)
    dict.each do |word|
      rxp = match ? /#{word}/ : /#{word}/i
      value.to_s.gsub!(rxp, func.call(word))
    end
    value
  end
  
  #This method scrambles data by rearranging the letters.
  def self.scramble(value, dict, match) 
    dict.each do |word|
      rxp = match ? /#{word}/ : /#{word}/i
      value.to_s.gsub!(rxp, word.split(//).shuffle.join(''))
    end
    value
  end

  #This method removes selected words from the string and replaces them
  #with nothing
  def self.remove(value, dict, match)
    dict.each do |word|
      rxp = match ? /#{word}/ : /#{word}/i
      value.to_s.gsub!(rxp, "")
    end
    value
  end

  #This method removes selected words from the string and replaces them
  #with 'swear' characters,such as '#$@!%&'
  def self.replace(value, dict, match)
    dict.each do |word|
      rxp = match ? /#{word}/ : /#{word}/i
      value.to_s.gsub!(rxp, word.split(//).map{|char| char = Cleaner::Data.replacement_chars.shuffle[0]}.join(''))
    end
    value
  end
end
