require "rubygems"
require "rubygems/mock_gem_ui"
require "minitest/spec"
require "tmpdir"
require "fileutils"

class Gem::Commands::CreateCommand::TestCase < MiniTest::Spec
  # Apply this TestCase to any specs with
  # `describe Gem::Commands::CreateCommand`
  register_spec_type /Gem::Commands::CreateCommand/, self

  # Clear the tmpdir if needed.
  before { self.class.rm_tmpdir }

  # Create a temporary directory.
  def self.tmpdir
    @tmpdir ||= Dir.mktmpdir
  end

  # Remove the temporary directory.
  def self.rm_tmpdir
    FileUtils.rm_r(tmpdir) if File.exists?(tmpdir)
  ensure
    @tmpdir = nil
  end

  # Shortcut for specs dealing with generated files.
  #
  # Asserts that the file exists within the temporary directory.
  #
  # path - Path to the subject file
  #
  # If a block is given, it yields the contents of the file.
  #
  # Examples:
  #
  #     it_renders "README" do |data|
  #       data.must_match /Hello World!/
  #     end
  #
  #     it_renders "Gemspec"
  def self.it_renders(path)
    it "renders #{path}" do
      file = File.join(self.class.tmpdir, path)
      File.exists?(file).must_equal true, "Expected #{path.inspect} to exist"

      yield File.read(file) if block_given?
    end
  end

  # Returns a Gem::MockGemUI. This allows us to work with IO in tests.
  def ui
    @ui ||= Gem::MockGemUi.new
  end

  # Run the CreateCommand with the specified arguments.
  #
  # Returns an Array, [0] is the standard output of the command, [1] is the
  # error output.
  def run_command(*args)
    cmd = Gem::Commands::CreateCommand.new

    Dir.chdir(self.class.tmpdir) do
      Gem::DefaultUserInteraction.use_ui(ui) do
        capture_io { cmd.invoke *args }
      end
    end

    return ui.output, ui.error
  end

  def fixtures_path
    File.expand_path('../../fixtures', __FILE__)
  end
end

MiniTest::Unit.after_tests { Gem::Commands::CreateCommand::TestCase.rm_tmpdir }
