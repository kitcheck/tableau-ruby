require_relative 'test_helper'

class TestSite < TableauTest
  def test_site_finding
    VCR.use_cassette("tableau_site_find", :erb => true) do
      site = @client.sites.find_by(name: ENV['TABLEAU_DEFAULT_SITE'])
      assert site[:name]
      assert site[:id]
    end
  end

  def test_site_listing
    VCR.use_cassette("tableau_site_list", :erb => true) do
      sites = @client.sites.all 
      assert sites[:sites].is_a? Array
    end
  end
end
