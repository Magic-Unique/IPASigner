Pod::Spec.new do |s|
  s.name             = "MachOKit"
  s.version          = "0.1.0"
  s.summary          = "libMachO is a lightweight, C library for parsing in-memory Mach-O images."

  s.description      = <<-DESC
                        libMachO is a lightweight, C library for parsing in-memory Mach-O images.
                        It should not be used to parse binaries which have not been loaded into memory
                        by the kernel/dyld. To keep the library lightweight libMachO overlays itself
                        atop the MachO binary and provides a structured set of APIs to parse the data.
                        libMachO does not build up its own independent representation of the Mach-O
                        opting to continuously walk the Mach-O structures to access requested data.
                        This means that libMachO generally expects well-formed MachO binaries.
                       DESC

  s.homepage         = "https://github.com/DeVaukz/MachO-Kit"
  s.license          = 'MIT'
  s.author           = { "Devin Vaukz" => "devin.vaukz@gmail.com" }
  s.source           = { :git => "https://github.com/DeVaukz/MachO-Kit.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.6'
  s.watchos.deployment_target = '1.0'
  s.tvos.deployment_target = '9.0'
  
  s.source_files = 'MachOKit/**/*'
  
  s.requires_arc = false
  
  s.dependency "libMachO"
  
end
