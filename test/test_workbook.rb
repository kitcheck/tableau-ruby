require_relative 'test_helper'

class TestWorkbook < TableauTest
  def test_workbook_listing
    VCR.use_cassette("tableau_workbook_list", :erb => true) do
      workbooks = @client.workbooks.all(user_id: @admin_user[:id])
      assert workbooks[:workbooks].count > 0
      assert workbooks[:pagination].keys() == [:page_number, :page_size, :total_available]
    end
  end

  def test_workbook_find_by_name
    VCR.use_cassette("tableau_workbook_find", :erb => true) do
      all_workbooks = @client.workbooks.all(user_id: @admin_user[:id])
      workbook = @client.workbooks.find(site_id: @client.site_id, workbook_id: all_workbooks[:workbooks].first[:id])
      assert workbook[:id]
    end
  end

  def test_workbook_include_views
    VCR.use_cassette("tableau_workbook_views", :erb => true) do
      all_workbooks = @client.workbooks.all(user_id: @admin_user[:id])
      workbook = @client.workbooks.find(site_id: @client.site_id, workbook_id: all_workbooks[:workbooks].first[:id], include_views: true)
      assert workbook[:id]
      assert workbook[:views]
    end
  end

  def test_workbook_create_request
    VCR.use_cassette("tableau_workbook_project", :erb => true) do
      @project_id = @client.projects.all[:projects].first[:id]
    end
    Faraday::RackBuilder.any_instance.expects(:build_response).with do |*args|
      req = args[1]
      assert_equal req.method, :post
      assert_equal req.path, "/api/2.0/sites/#{@client.site_id}/workbooks"
      assert_equal req.headers["Content-Type"], "multipart/mixed; boundary=\"boundary-string\""

      uploaded_file = req.body
    end.raises("dont care")

    err = assert_raises(RuntimeError) {
      @client.workbooks.create(admin_password: ENV["TABLEAU_ADMIN_PASSWORD"], admin_username: ENV['TABLEAU_ADMIN_USER'], workbook_name: "test", project_id: @project_id, site_id: @client.site_id, file_path: Tempfile.new("superfly").path)
    }
    assert_equal err.message, "dont care"
  end

  def test_workbook_gets_created
    VCR.use_cassette("tableau_workbook_create", :erb => true) do
      project_id = @client.projects.all[:projects].detect{|i| i[:name] == "foobartest"}[:id]
      result = @client.workbooks.create(admin_password: ENV['TABLEAU_ADMIN_PASSWORD'], admin_username: ENV['TABLEAU_ADMIN_USER'], project_id: project_id, workbook_name: "fooboy", site_id: @client.site_id, file_path: File.dirname(__FILE__) + "/TestWorkbook.twb")
      assert_equal 201, result, "tableau workbook creation returns 201"
    end
  end
end
