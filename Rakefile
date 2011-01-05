desc "start from a freshly generated Rails Guides setup"
task :bootstrap do
  FileUtils.rm_rf(Dir["{assets,source,guides.yml}"])
  system "ruby bin/guides new . --name 'SproutCore Guides'"
  FileUtils.cp("bootstrap/guides.yml", "guides.yml")
  FileUtils.cp("bootstrap/overrides.css", "assets/stylesheets/overrides.style.css")
  FileUtils.cp("bootstrap/logo.png", "assets/images/logo.png")
  system "ruby bin/guides generate --clean"
end
