require 'openssl'
host = 'localhost'
subjectAltDomains = [ host, "pact-broker", "pact-broker-with-ngnix" ]

key = OpenSSL::PKey::RSA.new 2048
cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 1
cert.subject = OpenSSL::X509::Name.parse "CN=#{host}"
cert.issuer = cert.subject
cert.public_key = key.public_key
cert.not_before = Time.now
cert.not_after = cert.not_before + (100 * 365 * 24 * 60 * 60) # 100 years validity
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = cert
cert.extensions = [
  ef.create_extension("basicConstraints","CA:TRUE", true),
  ef.create_extension("subjectKeyIdentifier", "hash"),
]
cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                       "keyid:always,issuer:always")
cert.add_extension ef.create_extension("subjectAltName", subjectAltDomains.map { |d| "DNS: #{d}" }.join(','))
cert.sign(key, OpenSSL::Digest::SHA256.new)
File.open("ssl/self-signed-key.pem", "w") { |file| file << key.to_pem  }
File.open("ssl/self-signed-cert.pem", "w") { |file| file << cert.to_pem  }
