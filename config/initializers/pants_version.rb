rev_file = File.join(Rails.root, 'REVISION')
ENV['PANTS_VERSION'] = File.read(rev_file) if File.exist?(rev_file)