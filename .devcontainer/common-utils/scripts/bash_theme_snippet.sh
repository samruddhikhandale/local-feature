
# bash theme - partly inspired by https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/robbyrussell.zsh-theme
__bash_prompt() {
    local userpart='`export XIT=$? \
        && [ ! -z "${GITHUB_USER:-}" ] && echo -n "\[\033[0;32m\]@${GITHUB_USER:-} " || echo -n "\[\033[0;32m\]\u " \
        && [ "$XIT" -ne "0" ] && echo -n "\[\033[1;31m\]➜" || echo -n "\[\033[0m\]➜"`'
    local gitbranch='`\
        if [ "$(git config --get devcontainers-theme.hide-status 2>/dev/null)" != 1 ] && [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
            export BRANCH="$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)"; \
            if [ "${BRANCH:-}" != "" ]; then \
                echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH:-}" \
                && if [ "$(git config --get devcontainers-theme.show-dirty 2>/dev/null)" = 1 ] && \
                    git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                        echo -n " \[\033[1;33m\]✗"; \
                fi \
                && echo -n "\[\033[0;36m\]) "; \
            fi; \
        fi`'
    local lightblue='\[\033[1;34m\]'
    local removecolor='\[\033[0m\]'
    PS1="${userpart} ${lightblue}\w ${gitbranch}${removecolor}\$ "
    unset -f __bash_prompt
}
__bash_prompt
export PROMPT_DIRTRIM=4

# Check if the terminal is xterm
if [[ "$TERM" == "xterm" ]]; then
    # Function to set the terminal title to the current command
    preexec() {
        __current_command=""
        local cmd="${BASH_COMMAND}"
        echo -ne "\033]0;${USER}@${HOSTNAME}: ${cmd}\007"

        echo -ne "\e]463;A;${cmd}\a" # Command text
        echo -ne "\e]463;B\a" # Comamnd started
    }

    # Function to reset the terminal title to the shell type after the command is executed
    precmd() {
        RES="$?"
        echo -ne "\033]0;${USER}@${HOSTNAME}: ${SHELL}\007"

        if [ -z "$__current_command" ]; then
            echo -ne "\e]463;C\a" # Command ended (no exit code - actually no command)
        else
            echo -ne "\e]463;C;$RES\a" # Command ended
        fi

        # Make sure  downstream hooks get the correct exit code
        return $RES
    }

    # Trap DEBUG signal to call preexec before each command
    trap 'preexec' DEBUG

    # Prepend to PROMPT_COMMAND to call precmd before displaying the prompt
    PROMPT_COMMAND="precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND }"
fi
