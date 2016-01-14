#=============================================
# Enterprise Express Tasks
#=============================================
# Enterprise Express related tasks
namespace :mnoe do
  namespace :frontend do
    frontend_dist_folder = "public/dashboard"
    frontend_project_folder = 'frontend'
    frontend_tmp_folder = 'tmp/build/frontend'
    frontend_bower_folder = 'bower_components/mno-enterprise-angular'

    desc "Setup the Enterprise Express frontend"
    task :install do
      # Install required tools
      sh("npm install gulp gulp-util gulp-load-plugins del gulp-git")
      
      # Setup bower and dependencies
      bower_src = File.join(File.expand_path(File.dirname(__FILE__)),'templates','bower.json')
      cp(bower_src, 'bower.json')
      sh("bower install")

      # Create frontend override folder
      mkdir_p(frontend_project_folder)
      touch "#{frontend_project_folder}/.gitkeep"

      # Bootstrap override folder
      # Replace relative image path by absolute path in the LESS files
      mkdir_p("#{frontend_project_folder}/src/app/stylesheets")
      ['src/app/stylesheets/theme.less','src/app/stylesheets/variables.less'].each do |path|
        cp("#{frontend_bower_folder}/#{path}","#{frontend_project_folder}/#{path}")

        content = File.read("#{frontend_project_folder}/#{path}")
        File.open("#{frontend_project_folder}/#{path}", 'w') do |f|
          f << content.gsub("../images", frontend_dist_folder.gsub("public",""))
        end
      end

      # Build the frontend
      Rake::Task['mnoe:frontend:dist'].invoke
    end

    desc "Rebuild the Enterprise Express frontend"
    task :dist do
      # Reset tmp folder from mno-enterprise-angular source
      rm_rf "#{frontend_tmp_folder}/src"
      rm_rf "#{frontend_tmp_folder}/e2e"
      mkdir_p frontend_tmp_folder
      cp_r("#{frontend_bower_folder}/.","#{frontend_tmp_folder}/")

      # Apply frontend customisations
      cp_r("#{frontend_project_folder}/.","#{frontend_tmp_folder}/")

      # Build frontend using Gulp
      Dir.chdir(frontend_tmp_folder) do
        sh "npm install"
        sh "npm run gulp"
      end

      # Distribute file in public
      mkdir_p frontend_dist_folder
      cp_r("#{frontend_tmp_folder}/dist/.","#{frontend_dist_folder}/")
    end

  end
end
