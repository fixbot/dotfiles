require 'json'
require 'awesome_print'

TIME_TO_CHECK = 24 * 60 * 60 #Once per day

def should_sync?
  last_sync_time_string = File.read('$HOME/.dotfile_sync')
  last_sync = Time.parse(last_sync_time_string).to_i || 0
  Time.now.to_i > last_sync + TIME_TO_CHECK
rescue StandardError
  return true
end

def store_sync_time
  File.write('$HOME/.dotfiles/.last_sync', Time.now.to_s, "w")
end

def check_upstream_for_updates
  git_controller.pull
end

def check_local_files_for_updates
  return unless should_sync?
  require 'git'
  check_upstream_for_updates
  if count_not_synced > 0
    sync_upstream
  end
  git_controller.push
  store_sync_time
end

def git_controller
 #, :log => Logger.new(STDOUT))
 @git ||= Git.open('~/.dotfiles')
end

def sync_upstream
  git_controller.add
  commit_help = []
  commit_help << untracked.map {|f| "New File: #{f.path}"}
  commit_help << updated.map {|f| "Updated: #{f.path}"}
  hostname = `hostname`.strip
  uname = `uname`.strip
  git_controller.commit("Update #{Time.now.strftime('%m/%d/%Y')} #{hostname} #{uname} \n#{commit_help.join("\n")}")
end

def count_not_synced
  untracked.count + updated.count
end

def untracked
  current_status.select(&:untracked)
end

def updated
  current_status.reject { |f| f.type.nil? }
end

def current_status
  @current_status ||= git_controller.status
end

check_local_files_for_updates
