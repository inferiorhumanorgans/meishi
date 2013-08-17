class Quirks

  # @private
  def self.load_from_file(filename = 'config/quirks.yml')
    File.open(Rails.root.join(filename), 'r') do |f|
      y = YAML.load(f.read)
      y.each do |key, value|
        y[key] = value.collect{|s|
          # Serializing regular expressions is gross, so let's just look for
          # strings that look like regexps and leave everything else alone.
          if s =~ /^\/.*\/$/
            Regexp.new(s[1..-2])
          else
            s
          end
        }
      end

      y.default_proc = Proc.new {[]}

      y
    end
  end

  # @return [Hash] a hash containing all of the quirks and their match conditions.
  def self.defined_quirks
    Quirks::THE_QUIRKS.keys
  end

  # @param aQuirk [Symbol] the quirk to look up
  # @return [Array] an array of match conditions (strings for exact match, regexps for pattern matching) for a given quirk.
  # Looks up a quirk in the internal table.  An empty array is returned if the quirk is not found.
  def self.[](aQuirk)
    Quirks::THE_QUIRKS[aQuirk]
  end

  # Return true if our user agent string matches one of the regexps or
  # strings for the specified quirk.
  # @param aQuirk [Symbol] the quirk to look up
  # @param aUserAgent [String] the current user agent string
  def self.match(aQuirk, aUserAgent)
    Quirks[aQuirk].each do |user_agent_match|
      case user_agent_match.class.to_s
      when 'Regexp'
        return true if user_agent_match =~ aUserAgent
      else
        return true if user_agent_match == aUserAgent
      end
    end

    return false
  end

  Quirks.send(:remove_const, :THE_QUIRKS) if Quirks.const_defined? :THE_QUIRKS
  Quirks.const_set(:THE_QUIRKS, Quirks.load_from_file)

end
