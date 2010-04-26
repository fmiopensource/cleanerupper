# Cleanerupper #

Cleanerupper can be used in any ActiveRecord based model to seamless clean, sanitize, and
remove inappropriate or sensitive data.

# Using Cleanerupper #

Cleanerupper relies on a dictionary file located in the config directory of your rails
application called `dictionary.yml`.  This file is structured as so:

    words:
      these
      words
      will
      be
      cleaned

A default dictionary is included with this project, but only contains some test data for you to get started.  These words can be accessed via the `Cleaner::Data` object, which has several attributes:

    Cleaner::Data.dictionaries      => Hash of dictionary arrays from your file
    Cleaner::Data.replacement_chars => Array of characters to use for the `replace` method
    Cleaner::Data.file              => Filepath of the used dictionary file
    Cleaner::Data.cleaner_methods   => List of cleaner methods included in this release

It works by  providing a new method to all of your ActiveRecord based objects called `clean`

    class Widget < ActiveRecord::Base
      clean :body, :method => :scramble
    end

This method takes an array of columns to be cleaned by cleanerupper, followed by three optional parameters:

    :method     => Specifies which method to clean with
    :dictionary => Specifies which dictionaries should be used for this cleaning
    :callback   => Specifies a callback to call if disallowed data is found

Three methods have been provided for cleaning convenience, which are:

    :scramble => keeps all characters, but scrambles the word
    :remove   => removes the word completely
    :replace  => replaces all characters of the word with $%@^ text

If no method is defined, `:scramble` will be used.  You can also define your own function, like so:

    class Widget < ActiveRecord::Base
      clean :body, :method => :remove_vowels

      def custom(val)
        return val.gsub(/(a|e|i|o|u)/, "*")
      end
    end

In the example above, we make use of the `word` dictionary to check our column for bad words, as it is the default.  You can define a custom dictionary by creating a new top level key in your `dictionary.yml` file, like so:

    words:
      foo
      bar
    custom:
      baz

You can access these dictionaries by using the `Cleaner::Data.dictionaries[:key]` object, where `:key` is the key of your dictionary as defined by your config file.  You can specify that any cleaning method use a specific dictionary by adding a `:dictionary` paramater:

    class Widget < ActiveRecord::Base
      clean :body, :method => :replace, :dictionary => :custom
    end

You can also define a custom, dynamic dictionary by creating an instance method on your model.  This method should return an array of strings:

    class Widget < ActiveRecord::Base
      clean :body, :method => :remove, :dictionary => :user_names

      def user_names
        User.all.map(&:name)
      end
    end

If you create a method that has the same name as a defined dictionary in the `dictionary.yml` file, the one from the file will be used.  You can use multiple dictionaries for any given cleaning method by passing an array to the `:dictionary` option:

    class Widget < ActiveRecord::Base
      clean :body, :dictionary => [:words, :custom]
    end

You can also define a callback. This callback will only be called if bad data was found in any of
the columns.  If the callback returns false, the save will fail (this works the same way as a `before_save`).

    class Widget < ActiveRecord::Base
      clean :body, :method => :scramble, :callback => :found_words

      def found_words
        Emailer.email_teacher("Your student used a bad word!")
        true
      end
    end

# Examples #

    # Clean different columns with different methods
    class Widget < ActiveRecord::Base
      clean :body, :title, :method => :replace
      clean :author_name, :method => :scramble
    end

    # Clean the body, and send an email if this is the first time a bad word has been used
    class Widget < ActiveRecord::Base
      clean :body, :method => :replace, :callback => :send_email

      def send_email
        if self.author.infractions >= 1
          Mailer.send_infraction(self.author)
          return true
        end
        return false #Don't save this if they've already been notified about the rules!
      end
    end

    # Custom cleaning method
    class Widget < ActiveRecord::Base
      clean :body, :title, :author_name, :method => :remove_vowels

      def remove_vowels(val)
        val.gsub(/(a|e|i|o|u)/, "")
      end
    end

    # Custom dictionary
    class Widget < ActiveRecord::Base
      clean :body, :title, :method => :replace, :dictionary => :animals
    end

    # Custom dynamic dictionary
    class Widget < ActiveRecord::Base
      clean :body, :title, :method => :scramble, :dictionary => :user_names

      def user_names
        User.all.map(&:name)
      end
    end

    #Everything in one
    class Widget
      clean :body, :method => :remove_vowels, :dictionary => [:words, :user_names], :callback => :bad_word_found

      def remove_vowels(val)
        val.gsub(/(a|e|i|o|u)/, "*")
      end

      def user_names
        User.all.map(&:name)
      end

      def bad_word_found
        Emailer.notify_author_of_rejected_widget(self.author)
        return false #We do not want to save this bad widget
      end
    end

# Disclaimer #
This code is still under development, and as such, minor revisions may break compatibility with earlier versions of
the gem/plugin.  Please keep this in mind when using CleanerUpper.

# What's Next? #
* Optimize dictionary loops
* Benchmark the impact of the CleanerUpper codebase on database activity
* Remove test dependency on the rails environment

# Copyright and Licensing #
Copyright (c) 2010 Mike Trpcic (Fluid Media Inc.), released under the MIT license
