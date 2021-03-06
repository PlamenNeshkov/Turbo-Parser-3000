require 'octokit'
require 'colorize'

module TurboParser3000
  class GitHubAuth
    attr_accessor :client

    def initialize(username, password)
      @client = Octokit::Client.new(login: username, password: password)
      begin
        @client.authorizations
      rescue Octokit::Unauthorized
        puts "Wrong credentials, please try again.".red
        @client = nil
      end
    end
  end
end
