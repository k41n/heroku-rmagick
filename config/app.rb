class App < Configurable # :nodoc:
  config.aws_access_key = ENV['AWS_KEY']
  config.aws_secret_key = ENV['AWS_SECRET']
end
