require_relative 'test_helper'

class TestUsers < TableauTest
  def test_user_listing
    VCR.use_cassette("tableau_user_list", :erb => true) do
      all_users = @client.users.all
      assert all_users[:users].is_a? Array
      assert all_users[:users].size() > 0
    end
  end

  def test_user_find_by_id
    VCR.use_cassette("tableau_user_find", :erb => true) do
      admin_user = @client.users.find_by(id: @admin_user[:id])
      assert_equal @admin_user, admin_user
    end
  end

  def test_user_find_by_name
    VCR.use_cassette("tableau_user_find_name", :erb => true) do
      admin_user = @client.users.find_by(name: ENV['TABLEAU_ADMIN_USER'])
      assert_equal admin_user[:name], ENV['TABLEAU_ADMIN_USER']
      assert admin_user[:id]
    end
  end
end
