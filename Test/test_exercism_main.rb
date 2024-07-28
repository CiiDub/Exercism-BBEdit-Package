require 'minitest/autorun'
require 'open3'
require_relative '../Resources/exercism_main'
require_relative 'class_extentions'

describe 'Exercism' do
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
