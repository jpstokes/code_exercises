require './test/test_helper.rb'

describe TelegramBot do

  before do
    @user = TelegramBot::User.new(first_name: 'John', last_name: 'Doe', id: 1)
  end

  describe TelegramBot::User do
    it 'has require attributes' do
      assert_equal @user.first_name, 'John'
      assert_equal @user.last_name, 'Doe'
      assert_equal @user.full_name, 'John Doe'
      assert_equal @user.id, 1
      assert_equal @user.block_io_label, 'john_doe_1'
    end
  end

  describe TelegramBot::BlockIoClient do
    before do
      @client = TelegramBot::BlockIoClient.new
    end

    describe '#transfer_funds_to', vcr: true do
      it 'returns user_address' do
        response = @client.transfer_funds_to(@user)
        assert_equal response, { user_address: '2Mt7ZoTRekb3k8wJsKccVwDXxtNPRt5npVJ' }
      end
    end

    describe '#current_balance', vcr: true do
      it 'returns format in btc' do
        balance = @client.current_balance
        assert_equal balance, 0.11583056
      end

      it 'returns format in usd' do
        balance = @client.current_balance(nil, :usd)
        assert_equal balance, (0.11583056 * 3834.655).round(2)
      end
    end
  end

end
