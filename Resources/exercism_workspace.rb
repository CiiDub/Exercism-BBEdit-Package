# Module to help manage Exercism workspace including exercise dir's and files.
module ExercismWorkspaceAndExercises
  private

  def workspace?( cur_dir = Exercism::CURRENT_DIR, workspace = Exercism::WORKSPACE )
    cur_dir.start_with? workspace
  end

  def exercism_dir( cur_dir, search_iterations = 5 )
    previous_dir = Dir.pwd
    Dir.chdir cur_dir
    dir_search_result =
      loop.with_index( 1 ) do | _, parent_dirs_searched |
        break :out_of_workspace unless workspace?

        break Dir.pwd if Dir.children( Dir.pwd ).include? '.exercism'

        break :out_of_workspace if parent_dirs_searched >= search_iterations

        Dir.chdir '..'
      end
    Dir.chdir previous_dir
    display_outside_workspace_error( DOC, WORKSPACE ) if dir_search_result == :out_of_workspace

    dir_search_result
  end

  def exercise_exists?( track, exercise, workspace = Exercism::WORKSPACE )
    Dir.exist? File.join workspace, track, exercise
  end

  def exercise_filename( workspace, track, exercise )
    dir      = File.join workspace, track, exercise
    filename = Solutions.list( dir ).first
    File.join dir, filename
  end

  def save_doc( doc = Exercism::DOC )
    system 'osascript', '-e', "tell application \"BBEdit\" to save document \"#{doc}\""
  end

  def tag_exercise( success, tag_name, dir )
    Dir.chdir '../../Resources' do
      cmd = success ? 'success' : 'fail'
      system 'osascript', 'finder_tag_setter.applescript', cmd, tag_name, dir, out: File::NULL
    end
  end
end
