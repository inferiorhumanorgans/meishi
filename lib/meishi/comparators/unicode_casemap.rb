# Per 5051
class Comparators::UnicodeCasemap < Comparators::Octet
  def self.compare(a, b)
    a_string = UnicodeUtils.nfkd (UnicodeUtils.titlecase(a.clone))
    b_string = UnicodeUtils.nfkd (UnicodeUtils.titlecase(b.clone))

    super(a_string, b_string)
  end
end
