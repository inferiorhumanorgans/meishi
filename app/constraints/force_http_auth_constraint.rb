class ForceHTTPAuthConstraint
  def self.matches?(request)
    request.env["force_http_auth"] = true
    request.env["warden"].authenticate!
  end
end