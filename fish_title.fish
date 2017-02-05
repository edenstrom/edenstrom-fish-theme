function fish_title
  # Customize terminal window title

  set -l pwd (prompt_pwd)

  echo $pwd
end
