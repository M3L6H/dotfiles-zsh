# Override env to hide sensitive info
function env {
  output="$(/usr/bin/env "$@")" # Call original env
  awk -F '=' '
    {
      if (tolower($1) ~ /pwd|password|token/) {
        printf "%s=***\n",$1;
      } else {
        print;
      }
    }
  ' <<<"$output" | less
  return 0
}
