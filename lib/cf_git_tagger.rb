class CF_git_tagger
  def tag_commit_with_message(tag, commit_sha, message)
    puts "will tag commit with command 'git tag #{tag} #{commit_sha} -m #{message}'"

    `git tag #{tag} #{commit_sha} -m "#{message}"`
    `git push origin #{tag}`
  end
end