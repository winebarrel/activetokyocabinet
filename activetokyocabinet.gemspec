Gem::Specification.new do |spec|
  spec.name              = 'activetokyocabinet'
  spec.version           = '0.1.9'
  spec.summary           = 'ActiveTokyoCabinet is a library for using Tokyo(Cabinet|Tyrant) under ActiveRecord.'
  spec.files             = Dir.glob('lib/**/*') + Dir.glob('spec/**/*') + %w(README)
  spec.author            = 'winebarrel'
  spec.email             = 'sgwr_dts@yahoo.co.jp'
  spec.homepage          = 'http://activetokyocabi.rubyforge.org/'
  spec.has_rdoc          = true
  spec.rdoc_options      << '--title' << 'ActiveTokyoCabinet - a library for using Tokyo(Cabinet|Tyrant) under ActiveRecord.'
  spec.extra_rdoc_files  = %w(README)
  spec.rubyforge_project = 'activetokyocabinet'
  spec.add_dependency('activerecord')
end
