{
  "libxml2" =>       "2.6.26-2.1.2.8.el5_5.1",
  "libxml2-devel" => "2.6.26-2.1.2.8.el5_5.1",
  "libxslt" => "1.1.17-2",
  "libxslt-devel" => "1.1.17-2.el5_2.2",
}.each do |package_name, version_string|
  ['i386', 'x86_64'].each do |arch_string|
    package package_name do
      action :install
      version "#{version_string}.#{arch_string}"
    end
  end
end