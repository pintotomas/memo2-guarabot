require 'telegram/bot'
require File.dirname(__FILE__) + '/../app/routes'
require File.dirname(__FILE__) + '/../app/routes_inscription'

class BotClient
  def initialize(token = ENV['TELEGRAM_TOKEN'])
    @token = token
    @logger = Logger.new(STDOUT)
  end

  def start
    @logger.info "token is #{@token}"
    run_client do |bot|
      bot.listen { |message| handle_message(message, bot) }
    end
  end

  def run_once
    run_client do |bot|
      bot.fetch_updates { |message| handle_message(message, bot) }
    end
  end

  private

  def run_client(&block)
    Telegram::Bot::Client.run(@token, logger: @logger) { |bot| block.call bot }
  end

  def handle_message(message, bot)
    @logger.debug "@#{message.from.username}: #{message.inspect}"

    RoutesInscription.new.handle(bot, message)
  end
end
