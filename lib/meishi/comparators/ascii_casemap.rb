class Comparators::ASCIICasemap

  # -1: a < b
  #  0: a == b
  #  1: a > b
  # RFC 4790
  LOWERCASE_RANGE = ('a'.ord..'z'.ord)

  def self.compare(a, b)

    a_string = a.clone.force_encoding("ISO-8859-1")
    b_string = b.clone.force_encoding("ISO-8859-1")

    a_length = a_string.length
    b_length = b_string.length
    i = 0

    while true do
      return 0 if (a_length == 0) and (b_length == 0)

      return -1 if (a_length == 0)

      return 1 if (b_length == 0)

      a_ord = a_string[i].ord
      b_ord = b_string[i].ord

      if (a_ord != b_ord)
        if LOWERCASE_RANGE.include? a_ord
          a_ord = 'A'.ord + (a_ord - 'a'.ord)
        end

        if LOWERCASE_RANGE.include? b_ord
          b_ord = 'A'.ord + (b_ord - 'a'.ord)
        end

        return -1 if (a_ord < b_ord)

        return 1 if (b_ord < a_ord)
      end

      a_length -= 1
      b_length -= 1
      i += 1
    end
  end

end
