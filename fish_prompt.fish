set -g pad " "

set -g ITALIC_ON (tput sitm)
set -g ITALIC_OFF (tput ritm)

function __bobthefish_git_branch -S -d 'Get the current git branch (or commitish)'
  set -l ref (command git symbolic-ref HEAD ^/dev/null)
    and echo $__power_branch_glyph
    and echo $ITALIC_ON
    and echo $ref | sed "s#refs/heads/# #"
    and echo $ITALIC_OFF
    and return

  set -l tag (command git describe --tags --exact-match ^/dev/null)
    and echo $__power_tag_glyph
    and echo $ITALIC_ON
    and echo "$tag"
    and echo $ITALIC_OFF
    and return

  set -l branch (command git show-ref --head -s --abbrev | head -n1 ^/dev/null)
  echo $__power_detached_glyph
  echo $ITALIC_ON
  echo "$branch"
  echo $ITALIC_OFF
end

## Function to show a segment
function prompt_segment -d "Function to show a segment"
  # Get colors
  set -l bg $argv[1]
  set -l fg $argv[2]

  # Set 'em
  set_color -b $bg
  set_color $fg

  # Print text
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3]
  end
end

function show_git -d "Function to show the current git repo"
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set -l dirty   (command git diff --no-ext-diff --quiet --exit-code; or echo -n '*')
    set -l staged  (command git diff --cached --no-ext-diff --quiet --exit-code; or echo -n '~')
    set -l stashed (command git rev-parse --verify --quiet refs/stash >/dev/null; and echo -n '$')
    # set -l ahead   (__bobthefish_git_ahead)

    set -l new ''
    set -l show_untracked (command git config --bool bash.showUntrackedFiles)
    if [ "$theme_display_git_untracked" != 'no' -a "$show_untracked" != 'false' ]
      set new (command git ls-files --other --exclude-standard --directory --no-empty-directory)
      if [ "$new" ]
        if [ "$theme_avoid_ambiguous_glyphs" = 'yes' ]
          set new '...'
        else
          set new '…'
        end
      end
    end

    set -l flags "$dirty$staged$stashed$ahead$new"
    [ "$flags" ]
      and set flags " $flags"

    if [ "$dirty" ]
      set_color red
    else if [ "$staged" ]
      set_color yellow
    else
      set_color green
    end

    echo -ns (__bobthefish_git_branch) $flags ' '
  end
end

## Function to show current status
function show_status -d "Function to show the current status"
  if [ $RETVAL -ne 0 ]
    prompt_segment red white " ! "
    set pad " "
    end
  if [ -n "$SSH_CLIENT" ]
      prompt_segment blue white " SSH: "
      set pad ""
    end
end

## Show user if not default
function show_user -d "Show user"
  if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
    set -l host (hostname -s)
    set -l who (whoami)
    prompt_segment normal yellow " $who"

    # Skip @ bit if hostname == username
    if [ "$USER" != "$HOST" ]
      prompt_segment normal white "@"
      prompt_segment normal green "$host "
      set pad ""
    end
    end
end

# Show directory
function show_pwd -d "Show the current directory"
  set -l pwd (prompt_pwd)
  prompt_segment normal blue "$pad$pwd "
end

# Show prompt w/ privilege cue
function show_prompt -d "Shows prompt with cue for current priv"
  set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
    prompt_segment red white " ! "
    set_color normal
    echo -n -s " "
  else
    prompt_segment normal red "\$"
    prompt_segment normal white " "
    end

  set_color normal
end

## SHOW PROMPT
function fish_prompt
  # Powerline glyphs
  set -g __power_branch_glyph            \uE0A0
  set -g __power_right_black_arrow_glyph \uE0B0
  set -g __power_right_arrow_glyph       \uE0B1
  set -g __power_left_black_arrow_glyph  \uE0B2
  set -g __power_left_arrow_glyph        \uE0B3

  # Additional glyphs
  set -g __power_detached_glyph          \u27A6
  set -g __power_tag_glyph               \u2302
  set -g __power_nonzero_exit_glyph      '! '
  set -g __power_superuser_glyph         '$ '
  set -g __power_bg_job_glyph            '% '
  set -g __power_hg_glyph                \u263F

  set -g RETVAL $status
  show_status
  show_user
  show_pwd
  show_git
  show_prompt
end
