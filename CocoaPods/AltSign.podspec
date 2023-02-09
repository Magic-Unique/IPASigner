Pod::Spec.new do |spec|
  spec.name         = "AltSign"
  spec.version      = "0.1"
  spec.summary      = "Open source iOS code-signing framework."
  spec.description  = "iOS framework to manage Apple developer accounts and resign apps."
  spec.homepage     = "https://github.com/rileytestut/altsign"
  spec.license      = "MIT"
  # --- Add osx support ---
  spec.ios.deployment_target = "12.0"
  spec.osx.deployment_target = "10.12"
  # -----------------------
  spec.source       = { :git => "https://gitee.com/xteam/AltSign.git", :branch => 'master' } #, :submodules => true }

  spec.author             = { "Riley Testut" => "riley@rileytestut.com" }
  spec.social_media_url   = "https://twitter.com/rileytestut"
  
  # --- Remove .source_files, .resources, .library ---
  spec.public_header_files = "AltSign/**/*.h"
  # ---------------------------------------------
  
  spec.xcconfig = {
    "OTHER_CFLAGS" => "-DCORECRYPTO_DONOT_USE_TRANSPARENT_UNION=1"
  }
  
  # Somewhat hacky subspec usage to ensure directory hierarchies match what header includes expect.

  # --- Add 'Core' subspec without signing ability ---
  spec.subspec 'Core' do |base|
    base.source_files  = "AltSign/**/*.{h,m,mm,hpp,cpp}"
    base.exclude_files = "AltSign/Signing/ALTSigner.mm", "AltSign/Categories/NSFileManager+Apps.m", "AltSign/Model/ALTApplication.mm", "AltSign/ldid/*"
  end

  spec.subspec 'iOS' do |base|
    base.dependency 'AltSign/Core'
    base.dependency 'AltSign/CoreCrypto'
    # base.dependency 'AltSign/OpenSSL_iOS'
    base.dependency 'OpenSSL-Universal'
    base.pod_target_xcconfig = { "SYSTEM_HEADER_SEARCH_PATHS" => '${PODS_ROOT}/OpenSSL-Universal/ios/include"' }
  end

  spec.subspec 'macOS' do |base|
    base.dependency 'AltSign/Core'
    base.dependency 'AltSign/CoreCrypto'
    # base.dependency 'AltSign/OpenSSL_macOS'
    base.dependency 'OpenSSL-Universal'
    base.pod_target_xcconfig = { "SYSTEM_HEADER_SEARCH_PATHS" => '${PODS_ROOT}/OpenSSL-Universal/macosx/include"' }
  end
  # --------------------------
  
  spec.subspec 'OpenSSL_iOS' do |base|
    base.source_files  = "Dependencies/OpenSSL/ios/include/openssl/*.h"
    base.header_mappings_dir = "Dependencies/OpenSSL/ios/include"
    base.private_header_files = "Dependencies/OpenSSL/ios/include/openssl/*.h"
    base.vendored_libraries = "Dependencies/OpenSSL/ios/lib/libcrypto.a", "Dependencies/OpenSSL/ios/lib/libssl.a"
  end
  
  spec.subspec 'OpenSSL_macOS' do |base|
    base.source_files  = "Dependencies/OpenSSL/macos/include/openssl/*.h"
    base.header_mappings_dir = "Dependencies/OpenSSL/macos/include"
    base.private_header_files = "Dependencies/OpenSSL/macos/include/openssl/*.h"
    base.vendored_libraries = "Dependencies/OpenSSL/macos/lib/libcrypto.a", "Dependencies/OpenSSL/macos/lib/libssl.a"
  end
  
  spec.subspec 'ldid' do |base|
    base.source_files = "AltSign/ldid/*.{hpp,h,c,cpp}", "Dependencies/ldid/*.{hpp,h,c,cpp}"
    base.private_header_files = "AltSign/ldid/*.hpp", "Dependencies/ldid/*.{hpp,h}"
    base.header_mappings_dir = ""
  end
  
  spec.subspec 'plist' do |base|
    base.source_files  = "Dependencies/ldid/libplist/include/plist/*.h", "Dependencies/ldid/libplist/src/*.{c,cpp}", "Dependencies/ldid/libplist/libcnary/**/*.{h,c}"
    base.exclude_files = "Dependencies/ldid/libplist/include/plist/String.h", "Dependencies/ldid/libplist/include/plist/Node.h", "Dependencies/ldid/libplist/libcnary/cnary.c" # Conflict with string.h and node.h, so exclude them.
    base.private_header_files = "Dependencies/ldid/libplist/include/plist/*.h", "Dependencies/ldid/libplist/libcnary/**/*.h"
    base.header_mappings_dir = "Dependencies/ldid/libplist"
    
    # Add libplist include directory so we can still find String.h and Node.h when explicitly requested.
    # --- Use "${PODS_TARGET_SRCROOT}" replace "$(SRCROOT)/../Dependencies" ---
    base.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => '"${PODS_TARGET_SRCROOT}/AltSign/Dependencies/ldid/libplist/include" "${PODS_TARGET_SRCROOT}/AltSign/Dependencies/ldid/libplist/src"' }
    # -------------------------------------------------------------------------
  end
  
  spec.subspec 'minizip' do |base|
    base.source_files  = "Dependencies/minizip/*.{h,c}"
    base.exclude_files = "Dependencies/minizip/iowin32.*", "Dependencies/minizip/minizip.c", "Dependencies/minizip/miniunz.c"
    base.private_header_files = "Dependencies/minizip/*.h"
    base.header_mappings_dir = "Dependencies"
  end
  
  spec.subspec 'CoreCrypto' do |base|
    base.source_files  = "Dependencies/corecrypto/*.{h,m}"
    base.exclude_files = "Dependencies/corecrypto/ccperf.h"
    base.private_header_files = "Dependencies/corecrypto/*.h"
    base.header_mappings_dir = "Dependencies"
  end
  
  # --- Add 'Signing' subspec to keep signing ablility for 'Core' ---
  spec.subspec 'Signing' do |base|
    base.source_files = "AltSign/Signing/ALTSigner.mm", "AltSign/Categories/NSFileManager+Apps.m", "AltSign/Model/ALTApplication.mm", "AltSign/ldid/*"
    base.resources = "AltSign/Resources/apple.pem"
    base.library = "c++"
  end
  # -----------------------------------------------------------------
  
end
