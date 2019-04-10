Pod::Spec.new do |s|
    s.name         = 'Octopus'
    s.version      = '1.1.1'
    s.summary      = 'Octopus demo'
    s.homepage     = 'https://github.com/ChaselAn/Octopus'
    s.license      = 'MIT'
    s.authors      = {'ChaselAn' => '865770853@qq.com'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'https://github.com/ChaselAn/Octopus.git', :tag => s.version}
    s.source_files = 'Octopus/*.swift'
    s.requires_arc = true
    s.swift_versions = ['5.0', '4.2', '4.0']
end
