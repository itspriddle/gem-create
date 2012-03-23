require "rubygems"
require "rubygems/mock_gem_ui"
require "minitest/spec"
require "tmpdir"
require "fileutils"

class GemCommandSpec < MiniTest::Spec
  def self.tmpdir
    @tmpdir ||= Dir.mktmpdir
  end

  def self.rm_tmpdir
    FileUtils.rm_r(tmpdir)
  end

  def ui
    @ui ||= Gem::MockGemUi.new
  end

  def use_ui(&block)
    Dir.chdir(self.class.tmpdir) do
      Gem::DefaultUserInteraction.use_ui(ui, &block)
    end
  end

  def run_command(*args)
    cmd = Gem::Commands::CreateCommand.new

    # capture_io {
      use_ui { cmd.invoke *args }
    # }

    return ui.output, ui.error
  end

  def file(path)
    File.read(path)
  end

  def self.it_renders(path)
    it "renders #{path}" do
      file = File.join(self.class.tmpdir, path)
      assert File.exists?(file), "Expected #{path.inspect} to exist"

      yield File.read(file) if block_given?
    end
  end
end

MiniTest::Spec.register_spec_type /Gem::Commands/, GemCommandSpec
MiniTest::Unit.after_tests { GemCommandSpec.rm_tmpdir }
