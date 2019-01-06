# sample gems to use, but you can use different ones
require 'block_io'
require 'telegram/bot'

module TelegramBot
  DEFAULT_LABEL = 'default'

  class User
    attr_reader :id, :first_name, :last_name, :full_name

    def initialize(first_name:, last_name:, id:)
      @first_name = first_name
      @last_name = last_name
      @id = id
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def block_io_label
      full_name.downcase.gsub(' ', '_') + '_' + id.to_s
    end
  end

  class Server
    def initialize
      @client = BlockIoClient.new
    end

    def listen_to_telegram_bot
      token = ENV['TELEGRAM_BOT_API_TOKEN']
      user_message_counts = {}

      Telegram::Bot::Client.run(token) do |bot|
        bot.listen do |message|
          begin
            case message.text
            when '/testing'
              bot.api.send_message(chat_id: message.chat.id, text: "#{message.from.first_name}, I'm happy to see you know the importance of testing.")
            when '/start'
              bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
            when '/stop'
              bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
            else
              user = User.new(
                id: message.from.id,
                first_name: message.from.first_name,
                last_name: message.from.last_name
              )
              user_message_counts[user.id].nil? ? user_message_counts[user.id] = 1 : user_message_counts[user.id] += 1
              bot.api.send_message(chat_id: message.chat.id, text: "Message sent successfully.")
              if user_message_counts[user.id] == 3
                # award user with bitcoin
                result = @client.transfer_funds_to(user)
                raise Exception.new('There was a problem transferring funds.') unless result
                bot.api.send_message(chat_id: message.chat.id, text: "Congrats, #{user.first_name}, you've earned $1 worth of bitcoin!")
                bot.api.send_message(
                  chat_id: message.chat.id,
                  text: current_balance_display(result[:user_address])
                )
                user_message_counts.delete(user.id)
              else
                bot.api.send_message(chat_id: message.chat.id, text: "Message tally: #{user_message_counts[user.id]}")
              end
            end
          rescue Exception => e
            bot.api.send_message(chat_id: message.chat.id, text: e.message)
          end
        end
      end
    end

    private

      def current_balance_display(address)
        "Your current balance: #{@client.current_balance(address, :btc)} BTC / $#{@client.current_balance(address, :usd)} USD"
      end
  end

  class BlockIoClient
    def initialize
      BlockIo.set_options(api_key: ENV['BITCOIN_API_KEY'], pin: ENV['BITCOIN_SECRET_PIN'], version: 2)
    end

    def transfer_funds_to(user)
      from_address = get_or_create_address_by_label(DEFAULT_LABEL)
      to_address = get_or_create_address_by_label(user.block_io_label)
      transfer_amount = calculate_1_usd_of_bitcoin
      raise Exception.new('Transfer amount exceeds current balance') if transfer_amount > current_balance
      BlockIo.withdraw_from_addresses(amounts: transfer_amount, from_addresses: from_address, to_addresses: to_address)
      { user_address: to_address }
    end

    def current_balance(addresses = nil, format = nil)
      response = if addresses.nil?
        BlockIo.get_balance
      else
        BlockIo.get_address_balance addresses: addresses
      end
      if format == :usd
        ('%.2f' % (response['data']['available_balance'].to_f * usd_value).round(2)).to_f
      else
        response['data']['available_balance'].to_f
      end
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
        (1 / usd_value).round(8)
      end

      def usd_value
        # hide following line since BlockIo doesn't provide value for test accounts
        # @usd_value ||= BlockIo.get_current_price(price_base: 'USD')
        3834.655
      end
  end

end
