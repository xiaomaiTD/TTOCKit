#
#  Be sure to run `pod spec lint TTSource.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

    s.name         = "TTKit"
    s.version      = "1.0.4"
    s.summary      = " mvc."
    s.description  = <<-DESC
                easy to mvc.
                   DESC
    s.homepage     = "https://github.com/ttayaa/TTKit"
    s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
    s.author       = { "ttayaa" => "2087154267@qq.com" }
    s.platform     = :ios, "8.0"
    s.source       = { :git => "https://github.com/ttayaa/TTKit.git", :tag => "v#{s.version}" }
    #s.source_files  = "TTSource/**/*.{h,m,mm}"
    
    s.resource  = "TTKit/**/*.{png,xib,storyboard,plist,der,js,json,strings,imageset,xcassets}"
    s.requires_arc = true
    
    
    #s.source_files = 'TTKit/TTKitConfig.h'
    
    
    s.subspec 'All' do |ss|
        ss.source_files = 'TTKit/**/*.{h,m,mm}'
        ss.dependency 'SDWebImage'
        ss.dependency 'AFNetworking'
        ss.dependency 'YYModel'
    end
    
    s.subspec 'TTControllerCategory' do |ss|
        ss.source_files = 'TTKit/TTControllerCategory/**/*.{h,m,mm}'
    end
    
    s.subspec 'TTMVVM' do |ss|
        ss.source_files = 'TTKit/TTMVVM/**/*.{h,m,mm}'
    end
    
    s.subspec 'TTTools' do |ss|
        ss.source_files = 'TTKit/TTTools/**/*.{h,m,mm}'
        ss.dependency 'SDWebImage'
    end
    
    s.subspec 'TTNetwork' do |ss|
        ss.source_files = 'TTKit/TTNetwork/**/*.{h,m,mm}'
        ss.dependency 'AFNetworking'
        ss.dependency 'YYModel'
    end
    
    s.subspec 'TTSignal' do |ss|
        ss.source_files = 'TTKit/TTSignal/**/*.{h,m,mm}'
    end
    
    s.subspec 'TTRouter' do |ss|
        ss.source_files = 'TTKit/TTRouter/**/*.{h,m,mm}'
        ss.dependency 'YYModel'
    end
    
    

end