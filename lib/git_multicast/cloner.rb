require 'net/http'
require 'json'

module GitMulticast
  class Cloner
    def initialize(username, dir)
      @username = username
      @dir = dir
    end

    def clone!
      repos = RepositoryFetcher.get_all_repos_from_user(username)

      tasks = repos.map do |repo|
        Task.new(repo.name, make_command(repo))
      end

      TaskRunner.new(tasks).run!
    end

    protected

    attr_reader :username, :dir

    def make_command(repo)
      if repo.fork
        parent_repo = RepositoryFetcher.get_repo_parent(repo.url)
        "git clone #{repo.ssh_url} #{File.join(dir, repo.name)} && \
git -C \"#{File.join(dir, repo.name)}\" remote add upstream \
#{parent_repo.ssh_url} --fetch"
      else
        "git clone #{repo.ssh_url} #{File.join(dir, repo.name)}"
      end
    end
  end
end
