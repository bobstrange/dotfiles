
function create-ts-project {
  help() {
    cat <<EOF
Usage:
  create-ts-project <project_name>
Example:
  create-ts-project my_project
EOF
  }

  if [[ $# -ne 1 ]]; then
    help
    return
  fi

  local project_name
  project_name="$1"

  echo "Create ${project_name} directory"
  mkdir ${project_name}
  cd ${project_name}
  git init
  npx license $(npm get init.license) -o "$(npm get init.author.name)" > LICENSE
  npx gitignore ${lang_name}
  npm init -y
  npm install -D typescript @types/node
  npx tsc --init \
    --rootDir src \
    --outDir dist \
    --esModuleInterop \
    --resolveJsonModule \
    --lib es6,dom \
    --module commonjs
  npm install -D ts-node nodemon
  echo <<EOF
"scripts": {
  "start": "npm run dev:watch",
  "build": "tsc -p",
  "dev:watch": "nodemon --watch 'src/**/*.ts' --exec 'ts-node' src/index.ts"
}
EOF
  git add -A
  git commit -m "Initial commit"
}
