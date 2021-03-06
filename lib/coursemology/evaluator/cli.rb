# frozen_string_literal: true
require 'optparse'

class Coursemology::Evaluator::CLI
  Options = Struct.new(:host, :api_token, :api_user_email,
                       :one_shot, :poll_interval, :image_lifetime, :sleep_time)

  def self.start(argv)
    new.start(argv)
  end

  def start(argv)
    run(argv)
  end

  def run(argv)
    options = optparse!(argv)
    Coursemology::Evaluator.config.poll_interval =
      ::ISO8601::Duration.new("PT#{options.poll_interval}".upcase).to_seconds

    # Must include the time designator T if hours/minutes/seconds are required.
    Coursemology::Evaluator.config.image_lifetime =
      ::ISO8601::Duration.new("P#{options.image_lifetime}".upcase).to_seconds

    Coursemology::Evaluator::Client.initialize(options.host, options.api_user_email,
                                               options.api_token)

    # Sleep before start
    sleep(::ISO8601::Duration.new("PT#{options.sleep_time}".upcase).to_seconds)
    Coursemology::Evaluator::Client.new(options.one_shot).run
  end

  private

  # Parses the options specified on the command line.
  #
  # @param [Array<String>] argv The arguments specified on the command line.
  # @return [Coursemology::Evaluator::CLI::Options]
  def optparse!(argv) # rubocop:disable Metrics/MethodLength
    options = Options.new

    # default options for optional parameters
    options.poll_interval = '10S'
    options.image_lifetime = '1D'
    options.one_shot = false
    options.sleep_time = '0S'

    option_parser = OptionParser.new do |parser|
      parser.banner = "Usage: #{parser.program_name} [options]"
      parser.on('-hHOST', '--host=HOST', 'Coursemology host to connect to') do |host|
        options.host = host
      end

      parser.on('-tTOKEN', '--api-token=TOKEN') do |token|
        options.api_token = token
      end

      parser.on('-uUSER', '--api-user-email=USER') do |user|
        options.api_user_email = user
      end

      parser.on('-iINTERVAL', '--interval=INTERVAL') do |interval|
        options.poll_interval = interval
      end

      parser.on('-lLIFETIME', '--lifetime=LIFETIME') do |lifetime|
        options.image_lifetime = lifetime
      end

      parser.on('-o', '--one-shot') do
        options.one_shot = true
      end

      parser.on('-sSLEEP', '--sleep=SLEEPTIME') do |sleeptime|
        options.sleep_time = sleeptime
      end
    end

    option_parser.parse!(argv)
    options
  end
end
