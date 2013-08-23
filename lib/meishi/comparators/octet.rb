# Per RFC 4790
class Comparators::Octet
  def self.compare(a,b)
    a_length = a.length
    b_length = b.length
    i = 0

    while true do
      return 0 if (a_length == 0) and (b_length == 0)

      return -1 if (a_length == 0)

      return 1 if (b_length == 0)

      a_ord = a[i].ord
      b_ord = b[i].ord

      if (a_ord != b_ord)
        return (a_ord < b_ord) ? -1 : 1
      end

      a_length -= 1
      b_length -= 1
      i += 1
    end
  end
end
