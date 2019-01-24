# Thanks to https://philna.sh/blog/2019/01/10/how-to-start-a-node-js-project/

function create-project {
  help() {
    cat <<EOF
Usage:
  create-project <project_name> <programming_langage_name>
Example:
  create-project my_project node
EOF
  }

  if [[ $# -ne 2 ]]; then
    help
    return
  fi

  local project_name lang_name
  project_name="$1"
  lang_name="$2"

  echo "Create ${project_name} directory"
  mkdir ${project_name}
  cd ${project_name}
  git init
  npx license $(npm get init.license) -o "$(npm get init.author.name)" > LICENSE
  npx gitignore ${lang_name}
  # npx covgen "$(npm get init.author.email)"
  npm init -y
  git add -A
  git commit -m "Initial commit"
}
