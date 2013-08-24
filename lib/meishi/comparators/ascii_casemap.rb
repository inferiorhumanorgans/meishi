class Comparators::ASCIICasemap

  # -1: a < b
  #  0: a == b
  #  1: a > b
  # RFC 4790

  # SO GROSS
  def self.prepare(a)
    a.clone.force_encoding("ISO-8859-1").tr(('A'..'Z').to_a.to_s, ('a'..'z').to_a.to_s)
  end

  def self.compare(a, b)

    a_string = prepare(a)
    b_string = prepare(b)

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
        return -1 if (a_ord < b_ord)

        return 1 if (b_ord < a_ord)
      end

      a_length -= 1
      b_length -= 1
      i += 1
    end
  end

end
