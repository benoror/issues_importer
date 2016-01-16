require 'rubygems'
require 'bundler'
Bundler.require(:default)

# Modify your credentials here
BITBUCKET_USERNAME = "<user or org>"
BITBUCKET_PASSWORD = "<pass or api_key>"
BITBUCKET_REPONAME = "<repo_name>"

GITHUB_USERNAME = "<user>"
GITHUB_PASSWORD = "<pass or api_key>"
GITHUB_REPONAME = "<user or org>/<repo_name>"

# Script starts, no modification required after here
BITBUCKET = BitBucket.new login: BITBUCKET_USERNAME, password: BITBUCKET_PASSWORD
GITHUB = Octokit::Client.new login: GITHUB_USERNAME, password: GITHUB_PASSWORD

def extract_issues(status)
  result = []
  start = 0

  loop do
    issues = BITBUCKET.issues.list_repo BITBUCKET_USERNAME, BITBUCKET_REPONAME,
      limit: 50, start: start, sort: '-priority', status: status
    break if issues.count == 0

    result += issues
    start += 50
  end

  result
end

['new', 'open', 'on hold', 'resolved'].each do |status|
  issues = extract_issues(status)
  issues.each do |issue|
    labels = status + ',' + 'prio:' + issue.priority
    GITHUB.create_issue GITHUB_REPONAME, issue.title, issue.content, labels: labels
  end
end

