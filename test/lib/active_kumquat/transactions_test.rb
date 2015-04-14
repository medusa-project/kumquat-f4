require 'test_helper'

class TransactionsTest < ActiveSupport::TestCase

  class Foo
    include ActiveKumquat::Transactions
    attr_accessor :transaction_url
  end

  setup do
    @f4_url = Kumquat::Application.kumquat_config[:fedora_url].chomp('/')
    @obj = Foo.new
    @obj.transaction_url = @f4_url + '/tx:23942034982340'
    @non_tx_url = @f4_url + '/bla/bla/bla'
    @tx_url = @obj.transaction_url + '/bla/bla/bla'
  end

  test 'detransactionalized_url should work properly' do
    assert_equal @non_tx_url, @obj.detransactionalized_url(@tx_url)
  end

  test 'transactionalized_url should work properly' do
    assert_equal @tx_url, @obj.transactionalized_url(@non_tx_url)

    # don't transactionalize an already-transactional url
    assert_equal @tx_url, @obj.transactionalized_url(@tx_url)
  end

end
