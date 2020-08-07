#Code to generate certificates

# To generate a self signed CA certificate for use in a server:
# root_ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
# root_ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
# root_ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
# root_ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
# root_ca.add_extension(ef.create_extension("keyUsage","digitalSignature", true))

domain = "localhost"
subjectAltDomains = [ domain, "pact-broker", "pact-broker-with-ngnix" ]

require 'openssl'

root_key = OpenSSL::PKey::RSA.new 2048 # the CA's public/private key
root_ca = OpenSSL::X509::Certificate.new
root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
root_ca.serial = 1
root_ca.subject = OpenSSL::X509::Name.parse "/DC=org/DC=ruby-lang/CN=Ruby CA"
root_ca.issuer = root_ca.subject # root CA's are "self-signed"
root_ca.public_key = root_key.public_key
root_ca.not_before = Time.now
root_ca.not_after = root_ca.not_before + (100 * 365 * 24 * 60 * 60) # 100 years validity
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = root_ca
ef.issuer_certificate = root_ca
root_ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
root_ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
# root_ca.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
root_ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
root_ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)
File.open("ssl/cacert.pem", "w") { |file| file << root_ca.to_pem  }
File.open("ssl/cakey.pem", "w") { |file| file << root_key.to_pem  }


key = OpenSSL::PKey::RSA.new 2048
cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 2
cert.subject = OpenSSL::X509::Name.parse "/CN=#{domain}"
cert.issuer = root_ca.subject # root CA is the issuer
cert.public_key = key.public_key
cert.not_before = Time.now
cert.not_after = cert.not_before + (100 * 365 * 24 * 60 * 60) # 100 years validity
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = root_ca
cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
cert.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always,issuer:always"))
cert.add_extension ef.create_extension("subjectAltName", subjectAltDomains.map { |d| "DNS: #{d}" }.join(','))

cert.sign(root_key, OpenSSL::Digest::SHA256.new)
File.open("ssl/nginx.crt", "w") { |file| file << cert.to_pem  }
File.open("ssl/nginx.key", "w") { |file| file << key.to_pem }
