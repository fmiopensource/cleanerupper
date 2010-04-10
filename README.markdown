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

A default dictionary is included with this project, but only contains some test data for you to get started.  These words can be accessed via the `Cleaner::Dictionary` object, which has several dictionaries:

    Cleaner::Dictionary.words             => Array of words from the dictionary
    Cleaner::Dictionary.replacement_chars => Array of characters to use for the `replace` method
    Cleaner::Dictionary.file              => Filepath of the used dictionary file
    Cleaner::Dictionary.cleaner_methods   => List of cleaner methods included in this release

It works by  providing a new method to all of your ActiveRecord based objects called `clean`

    class Widget < ActiveRecord::Base
      clean :body, :with => :scramble
    end

This method takes an array of columns to be cleaned by cleanerupper, followed by two options:

    :with     => specifies which method to clean with
    :callback => specifies a callback to call if disallowed data is found

Three method have been provided for cleaning convenience, which are:

    :scramble => keeps all characters, but scrambles the word
    :remove   => removes the word completely
    :replace  => replaces all characters of the word with $%@^ text

If no method is defined, `:scramble` will be used.  You can also define your own function, like so:

    class Widget < ActiveRecord::Base
      clean :body, :with => :custom

      def custom(found)
        Cleaner::Dictionary.words.each do |word|
          found.gsub!(word, "CUSTOM") if found.include?(word)
        end
        return found
      end
    end

In the example above, we make use of the word dictionary to check our column for bad words.

You can also define a callback. This callback will only be called if bad data was found in any of
the columns.  If the callback returns falls, the save will fail (this works the same way as a `before_save`).

    class Widget < ActiveRecord::Base
      clean :body, :with => :scramble, :callback => :found_words

      def found_words
        Emailer.email_teacher("Your student used a bad word!")
        true
      end
    end


Examples
=======

    # Clean different columns with different methods
    class Widget < ActiveRecord::Base
      clean :body, :title, :with => :replace
      clean :author_name, :with => :scramble
    end

    # Clean the body, and send an email if this is the first time a bad word has been used
    class Widget < ActiveRecord::Base
      clean :body, :with => :replace, :callback => :send_email

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
      clean :body, :title, :author_name, :with => :remove_vowels

      def remove_vowels(found)
        Cleaner::Dictionary.words.each do |word|
          found.gsub!(/#{word}/, word.gsub(/(a|e|i|o|u)/, "")
        end
        return found
      end
    end

# Copyright and Licensing #
Copyright (c) 2010 Mike Trpcic (Fluid Media Inc.), released under the MIT license
