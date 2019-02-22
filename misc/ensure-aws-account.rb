#!/usr/bin/env ruby
unless defined?(Aws::STS)
  e = nil
  r = %w(aws-sdk-core aws-sdk).each do |x|
    require x
    break :ok
  rescue LoadError
    e = $!
    p e
    next
  end
  raise e unless r == :ok
end

module ::Cnw
  def self.ensure_aws_account(expected)
    account ||= Aws::STS::Client.new(region: 'ap-northeast-1').get_caller_identity().account
    raise "UNEXPECTED AWS ACCOUNT #{account} is given" unless account == expected
    p account
  end
end
