# Module used to download exercisms
module ExercismDownload
  private

  def confirm_and_download( workspace, track_exercise_hash )
    track     = track_exercise_hash['track']
    exercise  = track_exercise_hash['exercise']

    confirmation =
      if exercise_exists?( track, exercise )
        display_overwrite_confirmation track, exercise
      else
        display_download_confirmation track, exercise
      end

    case confirmation
    when /Download/ then download_exercise( workspace, track, exercise )
    when /Overwrite/ then download_exercise( workspace, track, exercise, force: true )
    when /Open/ then open_downloaded( workspace, track, exercise )
    else exit 0
    end
  end

  def download_exercise( workspace, track, exercise, force: false )
    overwrite = force ? '--force' : ''
    message   = Open3.capture2e( 'exercism', 'download', overwrite, "--track=#{track}", "--exercise=#{exercise}" ).first
    display_download_error( BBEditStyleLogWriter.clean_whitespace( message )) unless /^Downloaded to/.match? message

    open_downloaded workspace, track, exercise
  end

  def open_downloaded( workspace, track, exercise )
    file_path = exercise_filename workspace, track, exercise
    system 'open', '-a', 'BBEdit', file_path
  end

  def check_clipboard_for_exercism_command
    Open3.capture2e( 'pbpaste', '-pboard general' ).first
  end

  def check_browsers_for_exercism_url
    Dir.chdir '../../Resources' do
      Open3.capture2( 'osascript', 'get_ex_url.applescript' ).first.chomp.split "\n"
    end
  end

  def make_track_exercise_hash( *strs, regex )
    strs
      .flatten
      .uniq
      .map do | str |
        match = regex.match str
        next match if match.nil?

        match.named_captures
      end
  end
end
