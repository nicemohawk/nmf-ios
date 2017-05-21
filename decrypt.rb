#!/usr/bin/env ruby

require 'json'

header = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF

footer = <<EOF
</dict>
</plist>
EOF

values = []

# Decrypt secrets
secrets_ejson_path = `find . -name secrets.ejson`.strip
puts "Found secrets at #{secrets_ejson_path}"
secrets = `ejson -keydir /usr/local/ejson/keys decrypt #{secrets_ejson_path}`
puts 'Successfully decrypted'

# Parse secrets
json_secrets = JSON.parse(secrets)
json_secrets.collect do |key, value|
next if key == '_public_key'
values << "  <key>#{key}</key>"
values << "  <string>#{value}</string>"
end

secrets_plist_path = ENV["BUILT_PRODUCTS_DIR"] + "/" + ENV["PRODUCT_NAME"] + ".app/Secrets.plist"

puts "Writing secrets to #{secrets_plist_path}."

File.write(secrets_plist_path, header + values.join("\n") + footer)
