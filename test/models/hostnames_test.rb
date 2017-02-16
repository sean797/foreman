require 'test_helper'

class SmartProxyPoolTest < ActiveSupport::TestCase
  context 'hostname validations' do
    setup do
      @hostname = FactoryBot.build(:hostname)
    end

    test "should be valid" do
      assert_valid @hostname
    end

    test "should save" do
      assert @hostname.save
    end

    test "should save with the same smart proxy features" do
      proxy1 = FactoryBot.create(:smart_proxy, :features => [features(:dns)])
      proxy2 = FactoryBot.create(:smart_proxy, :features => [features(:dns)])

      mock_cert = mock()
      mock_cert.expects(:subject).at_least_once.returns(@hostname.hostname)
      mock_cert.expects(:subject_alternative_names).at_least_once
        .returns([proxy1.hostname, proxy2.hostname])
      CertificateExtract.expects(:new).twice.with(mock_cert).returns(mock_cert)

      mock_conn = mock()
      mock_conn.expects(:cert).at_least_once.returns(mock_cert)
      GetRawCertificate.expects(:new).with(proxy1.hostname, proxy1.port).returns(mock_conn)
      GetRawCertificate.expects(:new).with(proxy2.hostname, proxy2.port).returns(mock_conn)
      @hostname.smart_proxies = [proxy1, proxy2]
      assert @hostname.save
    end

    test "should fail with different smart proxy features" do
      @hostname.smart_proxies = [smart_proxies(:logs), smart_proxies(:bmc)]
      refute @hostname.save
    end

    test "should save if certs have valid san" do
      mock_cert = mock()
      mock_cert.expects(:subject).at_least_once.returns('proxy.example.com')
      mock_cert.expects(:subject_alternative_names).at_least_once.returns([@hostname.hostname])
      CertificateExtract.expects(:new).with(mock_cert).returns(mock_cert)

      mock_conn = mock()
      mock_conn.expects(:cert).at_least_once.returns(mock_cert)
      GetRawCertificate.expects(:new).with('proxy.example.com', 8443).returns(mock_conn)

      @hostname.smart_proxies = [FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')]
      assert @hostname.save
    end

    test "should fail if certs arent valid" do
      mock_cert = mock()
      mock_cert.expects(:subject).at_least_once.returns('proxy.example.com')
      mock_cert.expects(:subject_alternative_names).at_least_once.returns([])
      CertificateExtract.expects(:new).with(mock_cert).returns(mock_cert)

      mock_conn = mock()
      mock_conn.expects(:cert).at_least_once.returns(mock_cert)
      GetRawCertificate.expects(:new).with('proxy.example.com', 8443).returns(mock_conn)

      @hostname.smart_proxies = [FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')]
      refute @hostname.save
    end
  end

  test "proxy should respond correctly to has_feature? method" do
    assert hostnames(:puppetmaster).has_feature?('Puppet')
    refute hostnames(:realm).has_feature?('Puppet')
  end
end
