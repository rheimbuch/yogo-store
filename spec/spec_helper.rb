require 'pathname'
require 'fileutils'

spec_path = Pathname(__FILE__).dirname.expand_path.to_s
lib_path = (Pathname(spec_path).dirname + '..' + 'lib').expand_path.to_s

$:.unshift(lib_path) unless $:.include?(lib_path)

require 'yogo-store'


def tmp_path(path)
  tmp = (Pathname(__FILE__).dirname + 'tmp' + path).expand_path
  FileUtils.mkdir_p(tmp.to_s) unless tmp.exist?
  tmp
end


