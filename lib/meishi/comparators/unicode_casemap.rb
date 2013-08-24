# Per 5051
class Comparators::UnicodeCasemap < Comparators::Octet

  def self.prepare(a)
    UnicodeUtils.nfkd (UnicodeUtils.titlecase(a.clone))
  end

  def self.compare(a, b)
    a_string = prepare(a)
    b_string = prepare(b)

    super(a_string, b_string)
  end
end
