# sample gems to use, but you can use different ones
require 'block_io'
require 'telegram/bot'

module TelegramBot
  DEFAULT_LABEL = 'default'

  class User
    attr_reader :id, :first_name, :last_name, :full_name

    def initialize(user)
      @first_name = user.first_name
      @last_name = user.last_name
      @id = user.id
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def block_io_label
      full_name.downcase.gsub(' ', '_') + '_' + id.to_s
    end
  end

  class Server
    def listen_to_telegram_bot
      token = ENV['TELEGRAM_BOT_API_TOKEN']
      user_message_counts = {}

      Telegram::Bot::Client.run(token) do |bot|
        bot.listen do |message|
          case message.text
          when '/testing'
            bot.api.send_message(chat_id: message.chat.id, text: "#{message.from.first_name}, I'm happy to see you know the importance of testing.")
          when '/start'
            bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
          when '/stop'
            bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
          else
            user = User.new(message.from)
            user_message_counts[user.id].nil? ? user_message_counts[user.id] = 1 : user_message_counts[user.id] += 1
            if user_message_counts[user.id] == 3
              # award user with bitcoin
              result = BlockIoClient.new.transfer_funds_to(user)
              raise Exception.new('There was a problem transferring funds.') unless result
              bot.api.send_message(chat_id: message.chat.id, text: "Congrats, #{message.from.first_name}, you've earned $1 worth of bitcoin!")
              user_message_counts.delete(user.id)
            else
              bot.api.send_message(chat_id: message.chat.id, text: "Interesting!")
            end
          end
        end
      end
    rescue
      # TODO: log error
    end
  end

  class BlockIoClient
    def initialize
      BlockIo.set_options(api_key: ENV['BITCOIN_API_KEY'], pin: ENV['BITCOIN_SECRET_PIN'], version: 2)
    end

    def transfer_funds_to(user)
      from_address = get_or_create_address_by_label(DEFAULT_LABEL)
      to_address = get_or_create_address_by_label(user.block_io_label)
      BlockIo.withdraw_from_addresses(amounts: calculate_1_usd_of_bitcoin, from_addresses: from_address, to_addresses: to_address)
      true
    rescue Exception
      false
    end

    private

      def get_or_create_address_by_label(label)
        response = BlockIo.get_address_by_label(label: label)
        response['data']['address']
      rescue Exception
        response = BlockIo.get_new_address(label: label)
        response['data']['address']
      end

      def calculate_1_usd_of_bitcoin
        # hide following line since BlockIo doesn't provide value for test accounts
        # price = BlockIo.get_current_price(price_base: 'USD')
        price = 3834.655
        (1 / price).round(8).to_s
      end
  end

end
