class CF_git_tagger
  def tag_commit_with_message(tag, commit_sha, message)
    puts "will tag commit with command 'git tag #{tag} #{commit_sha} -m #{message}'"

    `git tag #{tagName} #{sha} -m "pushing to #{actual_env}"`
    `git push origin #{tagName}`
  end
end