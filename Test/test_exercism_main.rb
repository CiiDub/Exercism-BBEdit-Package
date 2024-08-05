require 'minitest/autorun'
require 'open3'
require_relative '../Resources/exercism_main'
require_relative 'class_extentions'

describe 'Exercism Download Methods' do
  before do
    Exercism.send( :remove_const, :WORKSPACE )
    Exercism::WORKSPACE = 'fake/workspace'.freeze
  end

  describe 'Exercism#download_exercise_with_clipboard' do
    subject do
      Exercism.extend TestFakes::Exercism::FromClipboard
    end

    before do
      @old_clipboard, _status = Open3.capture2e 'pbpaste'
      system 'pbcopy', '</dev/null'
    end

    after do
      system 'pbcopy', @old_clipboard
    end

    let( :copy_valid_command ) { Open3.pipeline ['echo', 'exercism download --track=ruby --exercise=fake-exercise'], 'pbcopy' }

    it 'no command found in clipboard' do
      error = expect { subject.download_exercise_with_clipboard }.must_raise StandardError
      value( error.message ).must_equal 'Clipboard Error'
    end

    it 'valid command in clipboard' do
      copy_valid_command

      expect( subject.download_exercise_with_clipboard ).must_equal ['fake/workspace', { 'track' => 'ruby', 'exercise' => 'fake-exercise' }]
    end
  end

  describe 'Exercism#download_exercise_with_website' do
    subject do
      Exercism.extend TestFakes::Exercism::FromWebsite
    end

    after do
      subject.test_url = nil
      subject.test_exercise_choice = nil
    end

    let( :valid_url ) { subject.test_url = 'https://exercism.org/tracks/ruby/exercises/fake-exercise' }

    let( :duplicate_urls ) { subject.test_url = ['https://exercism.org/tracks/ruby/exercises/fake-exercise', 'https://exercism.org/tracks/ruby/exercises/fake-exercise'] }

    let( :double_urls ) { subject.test_url = ['https://exercism.org/tracks/ruby/exercises/fake-exercise', 'https://exercism.org/tracks/ruby/exercises/fake-exercise-two'] }

    let( :choose_url1 ) { subject.test_exercise_choice = 0 }

    let( :choose_url2 ) { subject.test_exercise_choice = 1 }

    it 'no valid url' do
      error = expect { subject.download_exercise_with_website }.must_raise StandardError
      value( error.message ).must_equal 'Website Error'
    end

    it 'valid url' do
      valid_url

      expect( subject.download_exercise_with_website ).must_equal ['fake/workspace', { 'track' => 'ruby', 'exercise' => 'fake-exercise' }]
    end

    it 'two supported browsers with the same url' do
      duplicate_urls

      expect( subject.download_exercise_with_website ).must_equal ['fake/workspace', { 'track' => 'ruby', 'exercise' => 'fake-exercise' }]
    end

    it 'two supported browsers with different url - choose option 1 in simulated dialog box' do
      double_urls
      choose_url1

      expect( subject.download_exercise_with_website ).must_equal ['fake/workspace', { 'track' => 'ruby', 'exercise' => 'fake-exercise' }]
    end

    it 'two supported browsers with different url - choose option 2 in simulated dialog box' do
      double_urls
      choose_url2

      expect( subject.download_exercise_with_website ).must_equal ['fake/workspace', { 'track' => 'ruby', 'exercise' => 'fake-exercise-two' }]
    end
  end
end

describe 'Exercism *current exercise* methods' do
  before do
    Exercism.send( :remove_const, :DOC )
    Exercism.send( :remove_const, :CURRENT_DIR )
    Exercism.send( :remove_const, :WORKSPACE )
    Exercism::WORKSPACE = '/tmp/workspace'.freeze
    @test_dirs = FileUtils.mkdir_p(
      [
        '/tmp/workspace/track/exercise/.exercism',
        '/tmp/log'
      ]
    )
    Dir.chdir( @test_dirs.first ) do
      config_content = <<~JSON
        {
          "authors": [
            "chris"
          ],
          "contributors": [
            "chris"
          ],
          "files": {
            "solution": [
              "fake_exercise.rb"
            ],
            "test": [
              "fake_test.rb"
            ],
            "exemplar": [
              "fake_test.rb"
            ]
          },
          "language_versions": "salty",
          "blurb": "test text"
        }
      JSON
      File.write 'config.json', config_content
    end
  end

  after do
    workspace = File.expand_path '../../..', @test_dirs.first
    FileUtils.rm_r [workspace, @test_dirs[1]]
  end

  let( :not_an_exercise ) do
    Exercism::DOC = '/tmp/not_a_solution.txt'.freeze
    Exercism::CURRENT_DIR = '/tmp/'.freeze
  end

  let( :is_an_exercise ) do
    Exercism::DOC = '/tmp/workspace/track/exercise/fake_exercise.rb'.freeze
    Exercism::CURRENT_DIR = '/tmp/workspace/track/exercise'.freeze
  end

  describe '#open_current_exercise' do
    subject { Exercism.extend TestFakes::Exercism::OpenExercise }

    it 'outside Exercism workspace' do
      not_an_exercise

      error = expect { subject.open_current_exercise }.must_raise StandardError
      value( error.message ).must_equal 'Outside Workspace Error'
    end

    it 'return currect exercise directory' do
      is_an_exercise

      expect( subject.open_current_exercise ).must_equal '/private/tmp/workspace/track/exercise'
    end
  end

  describe 'test_current_exercise' do
    subject { Exercism.extend TestFakes::Exercism::TestExercise }

    before do
      BBEditStyleLogWriter.send( :remove_const, :LOG_DIR )
      BBEditStyleLogWriter::LOG_DIR = '/tmp/log'.freeze
      BBEditStyleLogWriter.include TestFakes::Exercism::BBEditStyleLogWriter
      Settings.extend TestFakes::Exercism::Settings
      @test_dir = Dir.pwd
      Dir.chdir '../Scripts/Exercism'
    end

    after do
      subject.saved = nil
      Settings.test_tag = nil
      Settings.save_on_test = nil
      Dir.chdir @test_dir
    end

    let( :successful_test ) do
      subject.fake_status = true
      subject.fake_test_results = 'Test Successful'
    end

    let( :failed_test ) do
      subject.fake_status = false
      subject.fake_test_results = 'Test Failed'
    end

    let( :tag_file ) do
      Settings.test_tag = 'Pass'
    end

    let( :auto_save ) do
      Settings.save_on_test = true
    end

    def was_dir_tagged?( tag, file )
      Open3.pipeline_r(
        ['xattr', '-xp', 'com.apple.metadata:_kMDItemUserTags', file],
        'xxd -r -p',
        'plutil -convert json -o - -',
        err: File::NULL
      ) do | output, _ |
        output.read.match?( /#{tag}\\n[0-9]/ )
      end
    end

    it 'outside Exercism workspace' do
      not_an_exercise

      error = expect { subject.test_current_exercise }.must_raise StandardError
      value( error.message ).must_equal 'Outside Workspace Error'
    end

    it 'successful test, no special settings' do
      is_an_exercise
      successful_test

      log_path = subject.test_current_exercise
      log_file = File.open( log_path, 'r' )
      log_contents = log_file.read.split( "\n" )
      value( log_path ).must_equal '/tmp/log/{⏜⏝⏜} track fake_exercise.log'
      value( log_file ).must_be_instance_of File
      value( log_contents.last ).must_equal 'Test Successful'
      expect( subject.saved? ).must_equal false
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal false
      log_file.close
    end

    it 'failed test' do
      is_an_exercise
      failed_test

      log_path = subject.test_current_exercise
      log_file = File.open( log_path, 'r' )
      log_contents = log_file.read.split( "\n" )
      value( log_path ).must_equal '/tmp/log/{⏜⏝⏜} track fake_exercise.log'
      value( log_file ).must_be_instance_of File
      value( log_contents.last ).must_equal 'Test Failed'
      expect( subject.saved? ).must_equal false
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal false
      log_file.close
    end

    it 'successful test, tag folder' do
      is_an_exercise
      successful_test
      tag_file

      subject.test_current_exercise
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal true
      expect( subject.saved? ).must_equal false
    end

    it 'failed test, tag folder' do
      is_an_exercise
      failed_test
      tag_file

      subject.test_current_exercise
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal false
      expect( subject.saved? ).must_equal false
    end

    it 'successful test, autosave' do
      is_an_exercise
      successful_test
      auto_save

      subject.test_current_exercise
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal false
      expect( subject.saved? ).must_equal true
    end

    it 'failed test, autosave' do
      is_an_exercise
      failed_test
      auto_save

      subject.test_current_exercise
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal false
      expect( subject.saved? ).must_equal true
    end

    it 'successful test, autosave and tag folder' do
      is_an_exercise
      successful_test
      auto_save
      tag_file

      subject.test_current_exercise
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal true
      expect( subject.saved? ).must_equal true
    end

    it 'failed test, autosave and tag folder' do
      is_an_exercise
      failed_test
      auto_save
      tag_file

      subject.test_current_exercise
      expect( was_dir_tagged?( 'Pass', Exercism::CURRENT_DIR )).must_equal false
      expect( subject.saved? ).must_equal true
    end
  end

  describe 'submit_current_exercise' do
    subject do
      Exercism.extend TestFakes::Exercism::SubmitExercise
      Exercism.extend TestFakes::Exercism::OpenExercise
    end

    before do
      BBEditStyleLogWriter.send( :remove_const, :LOG_DIR )
      BBEditStyleLogWriter::LOG_DIR = '/tmp/log'.freeze
      BBEditStyleLogWriter.include TestFakes::Exercism::BBEditStyleLogWriter
      Settings.extend TestFakes::Exercism::Settings
      @test_dir = Dir.pwd
      Dir.chdir '../Scripts/Exercism'
    end

    after do
      subject.saved = nil
      Settings.save_on_submit = nil
      Dir.chdir @test_dir
    end

    let( :successful_submission ) do
      subject.fake_status = true
      subject.fake_message = 'Submission Successful'
    end

    let( :failed_submission ) do
      subject.fake_status = false
      subject.fake_message = 'Submission Failed'
    end

    let( :auto_save ) do
      Settings.save_on_submit = true
    end

    it 'outside Exercism workspace' do
      not_an_exercise

      error = expect { subject.submit_current_exercise }.must_raise StandardError
      value( error.message ).must_equal 'Outside Workspace Error'
    end

    it 'failed submission' do
      is_an_exercise
      failed_submission

      error = expect { subject.submit_current_exercise }.must_raise StandardError
      value( error.message ).must_equal 'Submission Failed'
    end

    it 'successful submission, no special settings ' do
      is_an_exercise
      successful_submission

    end
  end
end
